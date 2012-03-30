# == Schema Information
#
# Table name: papers
#
#  id           :integer         not null, primary key
#  title        :string(255)
#  authors      :text
#  abstract     :text
#  identifier   :string(255)
#  url          :string(255)
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#  pubdate      :date
#  updated_date :date
#  scites_count :integer         default(0)
#

class Paper < ActiveRecord::Base
  attr_accessible :title, :authors, :abstract, :identifier, :url, :pubdate, :updated_date
  serialize :authors, Array

  has_many  :scites, dependent: :destroy
  has_many  :sciters, through: :scites, order: "name ASC"
  has_many  :comments, dependent: :destroy, order: "created_at ASC"

  validates :title, presence: true
  validates :authors, presence: true
  validates :abstract, presence: true
  validates :identifier, presence: true, uniqueness: true
  validates :url, presence: true
  validates :pubdate, presence: true
  validates :updated_date, presence: true

  validate  :updated_date_is_after_pubdate

  def to_param
    identifier
  end

  def updated?
    updated_date > pubdate
  end

  def self.last_date
    last = Paper.find(:first, order: "pubdate DESC")
    last.nil? ? Date.today : last.pubdate
  end

  def self.next_date(date)
    next_paper = Paper.find(:last,
                            order: "pubdate DESC",
                            conditions: ["pubdate > ?", date])
    next_paper.nil? ? nil : next_paper.pubdate
  end

  def self.prev_date(date)
    prev_paper = Paper.find(:first,
                            order: "pubdate DESC",
                            conditions: ["pubdate < ?", date])
    prev_paper.nil? ? nil : prev_paper.pubdate
  end


  private

    def updated_date_is_after_pubdate
      return unless pubdate and updated_date

      if updated_date < pubdate
        errors.add(:updated_date, "must not be earlier than pubdate")
      end
    end
end
