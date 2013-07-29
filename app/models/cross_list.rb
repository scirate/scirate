# == Schema Information
#
# Table name: cross_lists
#
#  id              :integer         primary key
#  paper_id        :integer
#  feed_id         :integer
#  cross_list_date :date
#  created_at      :timestamp       not null
#  updated_at      :timestamp       not null
#

class CrossList < ActiveRecord::Base
  belongs_to :paper
  belongs_to :feed

  validates :paper_id, presence: true
  validates :feed_id, presence: true
  validates :cross_list_date, presence: true
end
