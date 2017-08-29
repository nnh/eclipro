class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    can :create, Protocol
    can :read, Protocol do |protocol|
      protocol.participant?(user)
    end
    can [:update, :destroy, :build_team_form, :add_team, :admin], Protocol do |protocol|
      protocol.principal_investigator?(user) || protocol.co_author?(user)
    end

    can [:read, :history, :compare], Content do |content|
      content.protocol.participant?(user)
    end
    can [:update, :revert], Content do |content|
      content.protocol.updatable_sections(user).include?(content.no)
    end

    can :all, Comment do |comment|
      comment.content.protocol.participant?(user)
    end
  end
end
