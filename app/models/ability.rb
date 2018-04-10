class Ability
  include CanCan::Ability

  def initialize(user, params)
    user ||= User.new

    can :create, Protocol
    can [:read, :clone, :export, :select], Protocol, participations: { user_id: user.id }
    can [:destroy, :build_team_form, :add_team, :admin], Protocol do |protocol|
      protocol.admin?(user)
    end
    can [:update, :finalize], Protocol do |protocol|
      protocol.admin?(user) && !protocol.finalized?
    end
    can :reinstate, Protocol do |protocol|
      protocol.admin?(user) && protocol.finalized?
    end
    can :create_or_update, Protocol do |protocol|
      ((can? :create, protocol) && protocol.new_record?) || (can? :update, protocol)
    end

    can [:read, :history, :compare], Content do |content|
      content.protocol.participant?(user)
    end
    can :updatable, Content do |content|
      if content.protocol.finalized?
        false
      else
        user.updatable_sections(content.protocol).include?(content.no)
      end
    end
    can :reviewable, Content do |content|
      if content.protocol.finalized?
        false
      else
        user.reviewable_sections(content.protocol).include?(content.no)
      end
    end
    can [:update, :revert], Content do |content|
      if content.protocol.finalized? || (!content.status_new? && !content.in_progress?)
        false
      else
        can? :updatable, content
      end
    end
    can :review, Content do |content|
      if content.protocol.finalized? || !content.under_review?
        false
      else
        can? :reviewable, content
      end
    end
    can :change_status, Content do |content|
      if content.protocol.finalized?
        false
      else
        status = params[:content][:status]
        ((content.status_new? || content.in_progress?) && (can? :update, content) && status == 'under_review') ||
          (content.under_review? && (can? :updatable, content) && status == 'in_progress') ||
          (content.under_review? && (can? :reviewable, content) && (status == 'in_progress' || status == 'final')) ||
          (content.final? && ((can? :updatable, content) || (can? :reviewable, content)) && status == 'in_progress')
      end
    end
    can :rework, Content do |content|
      if content.protocol.finalized? || (!content.under_review? && !content.final?)
        false
      else
        (can? :updatable, content) || (can? :reviewable, content)
      end
    end

    can :manage, Comment do |comment|
      comment.content.protocol.participant?(user)
    end

    can :create, Image do |image|
      can? :update, image.content
    end
    can :read, Image do |image|
      can? :read, image.content
    end

    can :manage, Participation do |participation|
      can? :admin, participation.protocol
    end

    can :manage, ReferenceDocx do |docx|
      docx.protocol.admin?(user)
    end
    can :read, ReferenceDocx do |docx|
      docx.protocol.participant?(user)
    end
  end
end
