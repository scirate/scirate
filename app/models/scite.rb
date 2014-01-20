# == Schema Information
#
# Table name: scites
#
#  id         :integer          not null, primary key
#  paper_id   :integer          not null
#  user_id    :integer          not null
#  created_at :datetime
#  updated_at :datetime
#

class Scite < ActiveRecord::Base
  belongs_to :user, class_name: "User", counter_cache: true, touch: true
  belongs_to :paper, counter_cache: true, touch: true

  validates :user, presence: true
  validates :paper,  presence: true
end
