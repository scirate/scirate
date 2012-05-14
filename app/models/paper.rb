# == Schema Information
#
# Table name: papers
#
#  id             :integer         primary key
#  title          :string(255)
#  authors        :text
#  abstract       :text
#  identifier     :string(255)
#  url            :string(255)
#  created_at     :timestamp       not null
#  updated_at     :timestamp       not null
#  pubdate        :date
#  updated_date   :date
#  scites_count   :integer         default(0)
#  comments_count :integer         default(0)
#  feed_id        :integer
#

class Paper < ActiveRecord::Base
  attr_accessible :title, :authors, :abstract, :identifier, :url, :pubdate, :updated_date
  serialize :authors, Array

  belongs_to :feed

  has_many  :scites, dependent: :destroy
  has_many  :sciters, through: :scites, order: "name ASC"
  has_many  :comments, dependent: :destroy, order: "created_at ASC"
  has_many  :cross_lists, dependent: :destroy
  has_many  :cross_listed_feeds, through: :cross_lists, \
                source: :feed, order: "name ASC"

  validates :title, presence: true
  validates :authors, presence: true
  validates :abstract, presence: true
  validates :identifier, presence: true, uniqueness: true
  validates :url, presence: true
  validates :pubdate, presence: true
  validates :updated_date, presence: true
  validates :feed, presence: true

  validate  :updated_date_is_after_pubdate

  def to_param
    identifier
  end

  def updated?
    updated_date > pubdate
  end

  # Returns papers from feeds subscribed to by the given user
  scope :from_feeds_subscribed_by, lambda { |user| subscribed_by(user) }

  private

    def updated_date_is_after_pubdate
      return unless pubdate and updated_date

      if updated_date < pubdate
        errors.add(:updated_date, "must not be earlier than pubdate")
      end
    end

    # Returns SQL condition for papers from feeds subscribed
    # to by the given user.
    def self.subscribed_by(user)
      subscribed_ids = %(SELECT feed_id FROM subscriptions
                         WHERE user_id = ?)
      where("feed_id IN (#{subscribed_ids})", user.id)
    end
end
