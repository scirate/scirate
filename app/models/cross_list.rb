# == Schema Information
#
# Table name: cross_lists
#
#  id              :integer         not null, primary key
#  paper_id        :integer
#  feed_id         :integer
#  cross_list_date :date
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#

class CrossList < ActiveRecord::Base
  attr_accessible :feed_id, :cross_list_date

  belongs_to :paper
  belongs_to :feed

  validates :paper_id, presence: true
  validates :feed_id, presence: true
  validates :cross_list_date, presence: true
end
