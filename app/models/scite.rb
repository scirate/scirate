# == Schema Information
#
# Table name: scites
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  created_at :datetime
#  updated_at :datetime
#  paper_uid  :text             default(""), not null
#

class Scite < ActiveRecord::Base
  belongs_to :user, class_name: "User", touch: true
  belongs_to :paper, foreign_key: :paper_uid, primary_key: :uid, touch: true

  validates :user, presence: true
  validates :paper, presence: true

  after_create do
    Activity.scite.create!(subject: self, user: user)
  end

  after_save do
    paper.refresh_scites_count!
    user.refresh_scites_count!
  end

  after_destroy do
    paper.refresh_scites_count!
    user.refresh_scites_count!
    Activity.scite.where(subject: self, user: user).destroy_all
  end
end
