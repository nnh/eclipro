class Ability
  include CanCan::Ability

  def initialize(user, params)
    user ||= User.new

    can :create, Protocol
    can [:read, :clone, :export], Protocol, participations: { user_id: user.id }
    can [:destroy, :build_team_form, :add_team, :admin], Protocol do |protocol|
      protocol.principal_investigator?(user) || protocol.co_author?(user)
    end
    can [:update, :finalize], Protocol do |protocol|
      (protocol.principal_investigator?(user) || protocol.co_author?(user)) && !protocol.finalized?
    end
    can :reinstate, Protocol do |protocol|
      (protocol.principal_investigator?(user) || protocol.co_author?(user)) && protocol.finalized?
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
        content.protocol.updatable_sections(user).include?(content.no)
      end
    end
    can :reviewable, Content do |content|
      if content.protocol.finalized?
        false
      else
        content.protocol.reviewable_sections(user).include?(content.no)
      end
    end
    can [:update, :revert], Content do |content|
      if content.protocol.finalized? || (!content.status_new? && !content.in_progress?)
        false
      else
        content.protocol.updatable_sections(user).include?(content.no)
      end
    end
    can :review, Content do |content|
      if content.protocol.finalized? || !content.under_review?
        false
      else
        content.protocol.reviewable_sections(user).include?(content.no)
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
  end
end
