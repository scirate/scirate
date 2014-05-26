class Activity < ActiveRecord::Base
  enum event: [:scite, :comment, :subscribe]
  belongs_to :user
  belongs_to :subject, polymorphic: true


  validates :user, presence: true
end
