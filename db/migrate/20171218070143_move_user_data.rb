class MoveUserData < ActiveRecord::Migration[5.1]
  class AuthorUser < ApplicationRecord
  end
  class ReviewerUser < ApplicationRecord
  end
  class CoAuthorUser < ApplicationRecord
  end
  class PrincipalInvestigatorUser < ApplicationRecord
  end

  def up
    AuthorUser.all.each do |user|
      Participation.create(user_id: user.id, protocol_id: user.protocol_id,
                           sections: user.sections.split(',').map(&:to_i), role: 'author')
    end
    ReviewerUser.all.each do |user|
      Participation.create(user_id: user.id, protocol_id: user.protocol_id,
                           sections: user.sections.split(',').map(&:to_i), role: 'reviewer')
    end
    CoAuthorUser.all.each do |user|
      Participation.create(user_id: user.id, protocol_id: user.protocol_id, role: 'co_author')
    end
    PrincipalInvestigatorUser.all.each do |user|
      Participation.create(user_id: user.id, protocol_id: user.protocol_id, role: 'principal_investigator')
    end

    drop_table :author_users
    drop_table :reviewer_users
    drop_table :co_author_users
    drop_table :principal_investigator_users
  end

  def down
    create_table :author_users do |t|
      t.references :protocol, foreign_key: true
      t.references :user, foreign_key: true
      t.text :sections

      t.timestamps
    end
    create_table :reviewer_users do |t|
      t.references :protocol, foreign_key: true
      t.references :user, foreign_key: true
      t.text :sections

      t.timestamps
    end
    create_table :co_author_users do |t|
      t.references :protocol, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
    create_table :principal_investigator_users do |t|
      t.references :protocol, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
