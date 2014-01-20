# == Schema Information
#
# Table name: feeds
#
#  id                  :integer          not null, primary key
#  uid                 :text             not null
#  source              :text             not null
#  fullname            :text             not null
#  parent_id           :integer
#  position            :integer          default(0), not null
#  subscriptions_count :integer          default(0), not null
#  last_paper_date     :datetime
#

class Feed < ActiveRecord::Base
  belongs_to :parent, class_name: "Feed"
  has_many :subscriptions, dependent: :destroy
  has_many :users, through: :subscriptions
  has_many :categories, dependent: :destroy,
           foreign_key: :feed_uid, primary_key: :uid
  has_many :papers, through: :categories, source: :paper
  has_many :children, foreign_key: 'parent_id', class_name: 'Feed'

  validates :uid, presence: true, uniqueness: true
  validates :fullname, presence: true
  validates :source, presence: true

  default_scope { order(:position) }

  # Returns toplevel arxiv categories for sidebar
  def self.arxiv_folders
    @@arxiv_folders ||= Feed.where(uid: Settings::ARXIV_FOLDERS).includes(:children).to_a
  end

  def self.arxiv_import(uids, opts={})
    existing = Feed.all.map(&:uid)

    columns = [:uid, :fullname, :source]
    values = []

    (uids - existing).map do |uid|
      logger.info "Discovered new feed: #{uid}"
      values << [
        uid,
        uid.to_s,
        "arxiv"
      ]
    end

    result = Feed.import(columns, values, opts)
    unless result.failed_instances.empty?
      SciRate3.notify_error("Error importing feeds: #{result.failed_instances.inspect}")
    end
  end

  def self.find_by_uid(uid)
    @@uid_map ||= Feed.map_uids
    @@uid_map[uid]
  end

  def self.get_or_create(uid)
    feed = Feed.find_by_uid(uid)
    return feed unless feed.nil?
    feed = Feed.new
    feed.uid = uid
    feed.fullname = uid.to_s
    feed.source = 'arxiv'
    feed.save!
    feed
  end

  def self.map_uids
    mapping = {}
    Feed.all.each { |feed| mapping[feed.uid] = feed }
    mapping
  end

  def to_param
    uid
  end

  def update_last_paper_date
    uids = [self.uid] + self.children.pluck(:uid)
    category = Category.where(feed_uid: uids).order("crosslist_date ASC").last
    unless category.nil?
      self.last_paper_date = category.crosslist_date
      self.save!
    end
  end
end
