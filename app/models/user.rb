class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  def updatable_sections(protocol)
    @updatable_sections ||= {}
    @updatable_sections[protocol.id] ||= protocol.updatable_sections(self)
  end

  def reviewable_sections(protocol)
    @reviewable_sections ||= {}
    @reviewable_sections[protocol.id] ||= protocol.reviewable_sections(self)
  end
end
