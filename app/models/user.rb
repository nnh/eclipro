class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  def updatable(protocol)
    @updatable = {} if @updatable.nil?
    @updatable[protocol.id] ||= protocol.updatable_sections(self)
  end

  def reviewable(protocol)
    @reviewable = {} if @reviewable.nil?
    @reviewable[protocol.id] ||= protocol.reviewable_sections(self)
  end
end
