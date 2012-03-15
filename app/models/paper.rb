# == Schema Information
#
# Table name: papers
#
#  id         :integer         not null, primary key
#  title      :string(255)
#  authors    :text
#  abstract   :text
#  identifier :string(255)
#  url        :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#  pubdate    :date
#

class Paper < ActiveRecord::Base
  attr_accessible :title, :authors, :abstract, :identifier, :url, :pubdate
  serialize :authors, Array

  validates :title, presence: true
  validates :authors, presence: true
  validates :abstract, presence: true
  validates :identifier, presence: true, uniqueness: true
  validates :url, presence: true
  validates :pubdate, presence: true

  def to_param
    identifier
  end
end
