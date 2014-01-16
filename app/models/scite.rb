# == Schema Information
#
# Table name: scites
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  paper_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Scite < ActiveRecord::Base
  belongs_to :user, class_name: "User", counter_cache: true, touch: true
  belongs_to :paper, counter_cache: true, touch: true

  validates :user, presence: true
  validates :paper,  presence: true
end
