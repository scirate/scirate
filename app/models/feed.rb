# == Schema Information
#
# Table ident: feeds
#
#  id                  :integer          not null, primary key
#  ident                :string(255)
#  url                 :string(255)
#  source           :string(255)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  update_date        :date
#  subscriptions_count :integer          default(0)
#  last_paper_date     :date
#  fullident            :text
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

  validates :identifier, presence: true, uniqueness: true
  validates :name, presence: true
  validates :source, presence: true

  default_scope { order(:position) }

  # Returns toplevel arxiv categories for sidebar
  def self.arxiv_folders
    @@arxiv_folders ||= Feed.where(identifier: Settings::ARXIV_FOLDERS).includes(:children).to_a
  end

  def self.arxiv_import(idents, opts={})
    existing = Feed.all.map(&:identifier)

    columns = [:identifier, :name, :source]
    values = []

    (idents - existing).map do |ident|
      logger.info "Discovered new feed: #{ident}"
      values << [
        ident,
        ident.to_s,
        "arxiv"
      ]
    end

    result = Feed.import(columns, values, opts)
    unless result.failed_instances.empty?
      SciRate3.notify_error("Error importing feeds: #{result.failed_instances.inspect}")
    end
  end

  def self.find_by_identifier(ident)
    @@ident_map ||= Feed.map_idents
    @@ident_map[ident]
  end

  def self.get_or_create(ident)
    feed = Feed.find_by_identifier(ident)
    return feed unless feed.nil?
    feed = Feed.new
    feed.identifier = ident
    feed.name = ident.to_s
    feed.source = 'arxiv'
    feed.save!
    feed
  end

  def self.map_idents
    mapping = {}
    Feed.all.each { |feed| mapping[feed.identifier] = feed }
    mapping
  end

  def to_param
    identifier
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
end
