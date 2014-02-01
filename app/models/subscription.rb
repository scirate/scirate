# == Schema Information
#
# Table name: subscriptions
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  feed_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Subscription < ActiveRecord::Base
  belongs_to :user, counter_cache: true, touch: true
  belongs_to :feed, counter_cache: true,
             foreign_key: :feed_uid, primary_key: :uid

  validates :user_id, presence: true
  validates :feed_uid, presence: true
end
