class Ability
  include CanCan::Ability

  def initialize(user, params)
    user ||= User.new

    can :create, Protocol
    can [:read, :clone, :export], Protocol do |protocol|
      protocol.participant?(user)
    end
    can [:update, :destroy, :build_team_form, :add_team, :admin], Protocol do |protocol|
      protocol.principal_investigator?(user) || protocol.co_author?(user)
    end
    can :finalize, Protocol do |protocol|
      (protocol.principal_investigator?(user) || protocol.co_author?(user)) && protocol.status != 'finalized'
    end
    can :reinstate, Protocol do |protocol|
      (protocol.principal_investigator?(user) || protocol.co_author?(user)) && protocol.status == 'finalized'
    end

    can [:read, :history, :compare, :next, :previous], Content do |content|
      content.protocol.participant?(user)
    end
    can [:update, :revert], Content do |content|
      content.protocol.updatable_sections(user).include?(content.no)
    end
    can :review, Content do |content|
      content.protocol.reviewable_sections(user).include?(content.no)
    end
    can :change_status, Content do |content|
      status = params[:content][:status]
      ((content.status == 'status_new' || content.status == 'in_progress') && (can? :edit, content) && (status == 'under_review')) ||
        (content.status == 'under_review' && (can? :edit, content) && status == 'in_progress') ||
        (content.status == 'under_review' && (can? :review, content) && (status == 'in_progress' || status == 'final')) ||
        (content.status == 'final' && ((can? :review, content) || (can? :edit, content)))
    end

    can :manage, Comment do |comment|
      comment.content.protocol.participant?(user)
    end
  end
end
