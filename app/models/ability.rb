class Ability
  include CanCan::Ability

  def initialize(user, params)
    user ||= User.new

    can :create, Protocol
    can [:read, :clone, :export], Protocol do |protocol|
      protocol.participant?(user)
    end
    can [:destroy, :build_team_form, :add_team, :admin], Protocol do |protocol|
      protocol.principal_investigator?(user) || protocol.co_author?(user)
    end
    can [:update, :finalize], Protocol do |protocol|
      (protocol.principal_investigator?(user) || protocol.co_author?(user)) && protocol.status != 'finalized'
    end
    can :reinstate, Protocol do |protocol|
      (protocol.principal_investigator?(user) || protocol.co_author?(user)) && protocol.status == 'finalized'
    end
    can :create_or_update, Protocol do |protocol|
      ((can? :create, protocol) && protocol.new_record?) || (can? :update, protocol)
    end

    can [:read, :history, :compare, :next, :previous], Content do |content|
      content.protocol.participant?(user)
    end
    can :updatable, Content do |content|
      content.protocol.updatable_sections(user).include?(content.no) && !content.protocol.finalized?
    end
    can :reviewable, Content do |content|
      content.protocol.reviewable_sections(user).include?(content.no) && !content.protocol.finalized?
    end
    can [:update, :revert], Content do |content|
      content.protocol.updatable_sections(user).include?(content.no) &&
        (content.status_new? || content.in_progress?) &&
        !content.protocol.finalized?
    end
    can :review, Content do |content|
      content.protocol.reviewable_sections(user).include?(content.no) && content.under_review? && !content.protocol.finalized?
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
      (content.under_review? || content.final?) &&
        ((can? :updatable, content) || (can? :reviewable, content)) &&
        !content.protocol.finalized?
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
