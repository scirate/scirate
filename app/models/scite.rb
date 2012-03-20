# == Schema Information
#
# Table name: scites
#
#  id         :integer         not null, primary key
#  sciter_id  :integer
#  paper_id   :integer
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class Scite < ActiveRecord::Base
  attr_accessible :paper_id

  belongs_to :sciter, class_name: "User", counter_cache: true
  belongs_to :paper, counter_cache: true 

  validates :sciter, presence: true
  validates :paper,  presence: true
end
