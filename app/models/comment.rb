# == Schema Information
#
# Table name: comments
#
#  id                 :integer          not null, primary key
#  user_id            :integer          not null
#  score              :integer          default(0), not null
#  cached_votes_up    :integer          default(0), not null
#  cached_votes_down  :integer          default(0), not null
#  hidden             :boolean          default(FALSE), not null
#  parent_id          :integer
#  ancestor_id        :integer
#  created_at         :datetime
#  updated_at         :datetime
#  content            :text             not null
#  deleted            :boolean          default(FALSE), not null
#  paper_uid          :text             default(""), not null
#  hidden_from_recent :boolean          default(FALSE), not null
#

class Comment < ActiveRecord::Base
  belongs_to :user, counter_cache: true
  belongs_to :paper, foreign_key: :paper_uid, primary_key: :uid, touch: true

  belongs_to :parent, class_name: "Comment" # Immediate reply ancestor
  belongs_to :ancestor, class_name: "Comment" # Highest-level reply ancestor

  validates :user, :paper, :content, presence: true

  has_many :reports, class_name: "CommentReport"
  has_many :children, foreign_key: 'parent_id', class_name: 'Comment'

  has_many :history, class_name: "CommentChange"

  scope :visible, -> { where(hidden: false, deleted: false) }

  after_create do
    # Record initial creation event
    record_change!(CommentChange::CREATED, self.user_id)

    # Track who we've emailed so we don't send twice for the same comment
    emailed_users = []

    # Email on comment replies
    if parent && parent.user.email_about_replies
      UserMailer.delay.comment_alert(parent.user, self)
      emailed_users[parent.user.id] = true
    end

    # Email people who claim this paper via their arXiv author identifier
    paper.claimants.each do |author|
      if author.email_about_comments_on_authored
        UserMailer.delay.comment_alert(author, self) unless emailed_users[author.id]
        emailed_users[author.id] = true
      end
    end

    # Email any sciters who have opted in to alerts on scited papers
    paper.sciters.each do |sciter|
      if sciter.email_about_comments_on_scited
        UserMailer.delay.comment_alert(sciter, self) unless emailed_users[sciter.id]
        emailed_users[sciter.id] = true
      end
    end
  end

  after_save do
    paper.refresh_comments_count!
  end

  after_destroy do
    paper.refresh_comments_count!
  end

  acts_as_votable

  def record_change!(event, user_id)
    CommentChange.create!(
      comment_id: self.id,
      user_id: user_id,
      event: event,
      content: self.content
    )
  end

  def soft_delete!(user_id)
    update!(deleted: true)
    record_change!(CommentChange::DELETED, user_id)
  end

  def restore!(user_id)
    update!(deleted: false)
    record_change!(CommentChange::RESTORED, user_id)
  end

  def edit!(content, user_id)
    update!(content: content)
    record_change!(CommentChange::EDITED, user_id)
  end

  def submit_trackback
    trackback_url = "http://arxiv.org/trackback/#{paper_uid}"

    title = "#{user.fullname}: #{self.content[0..99]}"
    title += "..." if self.content.length > 100

    data = {
      title: title,
      excerpt: self.content,
      url: "https://scirate.com/arxiv/#{paper.uid}##{self.id}",
      blog_name: "SciRate"
    }

    u = URI.parse(trackback_url)
    res = Net::HTTP.start(u.host, u.port) do |http|
      http.post(u.request_uri, URI.encode_www_form(data), { 'Content-Type' => 'application/x-www-form-urlencoded; charset=utf-8' })
    end

    if res.code != '200'
      SciRate.notify_error("Error from arXiv trackback: #{res.code} #{res.body}")
    end
  end
end
