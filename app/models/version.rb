# == Schema Information
#
# Table name: versions
#
#  id        :integer          not null, primary key
#  position  :integer          not null
#  date      :datetime         not null
#  size      :string(255)
#  paper_uid :string(255)      not null
#

class Version < ActiveRecord::Base
  validates :paper_uid, presence: true
  validates :position, presence: true
  validates :date, presence: true
  validates :size, presence: true

  belongs_to :paper, foreign_key: :paper_uid, primary_key: :uid
end
