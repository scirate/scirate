# == Schema Information
#
# Table name: feeds
#
#  id                  :integer          not null, primary key
#  name                :string(255)
#  url                 :string(255)
#  feed_type           :string(255)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  update_date        :date
#  subscriptions_count :integer          default(0)
#  last_paper_date     :date
#  fullname            :text
#  parent_id           :integer
#  position            :integer
#

class Feed < ActiveRecord::Base
  belongs_to :parent, class_name: "Feed"
  has_many :papers, validate: false
  has_many :subscriptions, dependent: :destroy
  has_many :users, through: :subscriptions
  has_many :cross_lists, dependent: :destroy
  has_many :cross_listed_papers, through: :cross_lists, source: :paper
  has_many :children, foreign_key: 'parent_id', class_name: 'Feed'

  validates :name, presence: true, uniqueness: true
  validates :feed_type, presence: true

  default_scope { order(:position) }

  # Returns toplevel arxiv categories for sidebar
  def self.arxiv_folders
    @@arxiv_folders ||= Feed.where(name: Settings::ARXIV_FOLDERS).includes(:children).to_a
  end

  def self.arxiv_import(feednames, opts={})
    existing = Feed.all.map(&:name)

    columns = [:name, :url, :feed_type]
    values = []

    (feednames - existing).map do |feedname|
      logger.info "Discovered new feed: #{feedname}"
      values << [
        feedname,
        "http://export.arxiv.org/rss/#{feedname}",
        "arxiv"
      ]
    end

    result = Feed.import(columns, values, opts)
    unless result.failed_instances.empty?
      SciRate3.notify_error("Error importing feeds: #{result.failed_instances.inspect}")
    end
  end

  def self.find_by_name(name)
    @@name_map ||= Feed.map_names
    @@name_map[name]
  end

  def self.get_or_create(name)
    feed = Feed.find_by_name(name)
    return feed unless feed.nil?
    feed = Feed.new
    feed.name = name
    feed.url = "http://export.arxiv.org/rss/#{name}"
    feed.feed_type = 'arxiv'
    feed.save!
    feed
  end

  def self.map_names
    mapping = {}
    Feed.all.each { |feed| mapping[feed.name] = feed }
    mapping
  end

  def to_param
    name
  end

  def self.default
    Feed.find_by_name("quant-ph") || Feed.create_default
  end

  def is_default?
    self == Feed.default
  end

  def self.create_default
    Feed.create(name: "quant-ph",
                url: "http://export.arxiv.org/rss/quant-ph",
                feed_type: "arxiv",
                last_paper_date: Time.now.utc.to_date)
  end

  def aggregated_papers
    feed_ids = [self.id] + self.children.map(&:id)
    Paper.joins(:cross_lists).where(cross_lists: { feed_id: feed_ids })
  end

  def update_last_paper_date
    paper = self.aggregated_papers.order("submit_date asc").last
    unless paper.nil?
      self.last_paper_date = paper.submit_date
      self.save!
    end

    self.parent.update_last_paper_date unless self.parent.nil?
  end

  def identifier
    "#{self.feed_type}/#{self.name}"
  end
end
