# == Schema Information
#
# Table name: versions
#
#  id        :integer          not null, primary key
#  position  :integer          not null
#  date      :datetime         not null
#  size      :text
#  paper_uid :text             not null
#

class Version < ActiveRecord::Base
  validates :paper_uid, presence: true
  validates :position, presence: true
  validates :date, presence: true
  validates :size, presence: true

  belongs_to :paper, foreign_key: :paper_uid, primary_key: :uid

  after_save do
    paper.refresh_versions_count!
  end

  after_destroy do
    paper.refresh_versions_count!
  end
end
