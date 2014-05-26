# == Schema Information
#
# Table name: subscriptions
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  feed_uid   :text             default(""), not null
#

class Subscription < ActiveRecord::Base
  belongs_to :user, counter_cache: true, touch: true
  belongs_to :feed, counter_cache: true,
             foreign_key: :feed_uid, primary_key: :uid

  validates :user_id, presence: true
  validates :feed_uid, presence: true

  after_create do
    Activity.subscribe.create(user: user, subject: self)
  end

  after_destroy do
    Activity.subscribe.where(user: user, subject: self).destroy_all
  end
end
