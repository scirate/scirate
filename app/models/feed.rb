class Feed < ActiveRecord::Base
  attr_accessible :name, :url, :feed_type

  has_many :papers

  validates :name, presence: true, uniqueness: true
  validates :url, presence: true, uniqueness: true
  validates :feed_type, presence: true

  def self.default
    default = Feed.find_by_name("quant-ph") || Feed.create_default
  end

  def last_date
    last = papers.find(:first, order: "pubdate DESC")
    last.nil? ? Date.today : last.pubdate
  end

  def next_date(date)
    next_paper = papers.find(:last,
                            order: "pubdate DESC",
                            conditions: ["pubdate > ?", date])
    next_paper.nil? ? nil : next_paper.pubdate
  end

  def prev_date(date)
    prev_paper = papers.find(:first,
                            order: "pubdate DESC",
                            conditions: ["pubdate < ?", date])
    prev_paper.nil? ? nil : prev_paper.pubdate
  end

  def is_default?
    self == Feed.default
  end

  def self.create_default
    Feed.create(name: "quant-ph",
                url: "http://export.arxiv.org/rss/quant-ph",
                feed_type: "arxiv")
  end
end
