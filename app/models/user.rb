# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  fullname               :text
#  email                  :text
#  remember_token         :text
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  password_digest        :text
#  scites_count           :integer          default(0)
#  password_reset_token   :text
#  password_reset_sent_at :datetime
#  confirmation_token     :text
#  active                 :boolean          default(FALSE)
#  comments_count         :integer          default(0)
#  confirmation_sent_at   :datetime
#  subscriptions_count    :integer          default(0)
#  expand_abstracts       :boolean          default(FALSE)
#  account_status         :text             default("user")
#  username               :text             not null
#

require 'open-uri'
require 'ostruct'
require 'data_helpers'

class Activity < OpenStruct
end

class User < ActiveRecord::Base
  STATUS_ADMIN = 'admin'
  STATUS_MODERATOR = 'moderator'
  STATUS_USER = 'user'
  STATUS_SPAM = 'spam'
  ACCOUNT_STATES = [STATUS_ADMIN, STATUS_MODERATOR, STATUS_USER, STATUS_SPAM]

  # We don't use the default validations because if users sign up
  # with oauth they don't need a password.
  has_secure_password(validations: false)
  attr_accessor :password_confirmation

  has_many :scites, dependent: :destroy
  has_many :scited_papers, through: :scites, source: :paper
  has_many :authorships, dependent: :destroy, class_name: 'Authorship'
  has_many :authored_papers, through: :authorships, source: :paper
  has_many :comments, -> { order('created_at DESC') }, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :feed_preferences, dependent: :destroy
  has_many :auth_links, dependent: :destroy
  has_many :feeds, through: :subscriptions

  validates :fullname, presence: true, length: { maximum: 50 }

  valid_email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, format: { with: valid_email_regex },
                    uniqueness: { case_sensitive: false }

  valid_username_regex = /\A[a-zA-Z0-9\-_\.]+\z/i
  validates :username, presence: true,
            format: { with: valid_username_regex, message: "may only contain alphanumeric characters and - or _" },
                    uniqueness: { case_sensitive: false }

  valid_aid_regex = /\A[a-z0-9_]+\z/
  validates :author_identifier,
            format: { with: valid_aid_regex, message: "must be a valid arXiv author id" },
            allow_blank: true

  validate do |user|
    # Only need a password if it's not oauth
    needs_password = user.auth_links.empty? && user.password_digest.nil?

    if needs_password && user.password.nil?
      user.errors.add :password, "must be present"
    end

    if user.password && user.password.length < 6
      user.errors.add :password, "must be at least 6 characters"
    end

    if user.password && user.password_confirmation != user.password
      user.errors.add :password, "must match password confirmation"
    end

    if user.username && Settings::RESERVED_USERNAMES.include?(user.username.downcase)
      user.errors.add :username, "is already taken"
    end
  end

  acts_as_voter

  before_save do
    # Reset the user session if vital information changes
    if new_record? || password_digest_changed? || email_changed?
      generate_token(:remember_token)
    end

    if author_identifier_changed?
      authorships.destroy_all
      self.papers_count = 0

      update_authorship!(true) unless author_identifier.empty?
    end

    # Switching to/from spam needs propagation to comments
    if account_status_changed?
      if account_status == STATUS_SPAM
        self.comments.update_all(hidden: true)
      else
        self.comments.update_all(hidden: false)
      end
    end
  end

  # Tell Rails routes to use our username
  # instead of id in generating urls
  def to_param
    username
  end

  def self.find_by_username(username)
    User.where("lower(username) = ?", username.downcase).first
  end

  def self.default_username(fullname)
    "#{fullname.parameterize}" + "-#{User.count}"
  end

  def scited?(paper)
    scites.find_by_paper_uid(paper.uid)
  end

  def scite!(paper)
    unless scites.find_by_paper_uid(paper.uid)
      scites.create!(paper_uid: paper.uid)
    end
  end

  def unscite!(paper)
    scites.find_by_paper_uid(paper.uid).destroy
  end

  def refresh_scites_count!
    self.scites_count = Scite.where(user_id: id).count
    save!
  end

  # Given a collection of papers, map uids to scite status
  def scited_by_uid(papers)
    map_exists :paper_uid, scites.where(paper_uid: papers.map(&:uid))
  end

  def subscribe!(feed)
    unless subscriptions.find_by_feed_uid(feed.uid)
      subscriptions.create!(feed_uid: feed.uid)
    end
  end

  def unsubscribe!(feed)
    subscriptions.find_by_feed_uid(feed.uid).destroy
  end

  def subscribed?(feed)
    subscriptions.find_by_feed_uid(feed.uid)
  end

  def has_subscriptions?
    subscriptions.size > 0
  end

  def feed_last_paper_date
    feed = feeds.where("last_paper_date IS NOT NULL").order("last_paper_date DESC").first
    feed && feed.last_paper_date.to_date
  end

  def send_signup_confirmation
    generate_token(:confirmation_token)
    save!
    UserMailer.signup_confirmation(self).deliver
  end

  def send_password_reset
    generate_token(:password_reset_token)
    save!
    UserMailer.password_reset(self).deliver
  end

  def clear_password_reset
    clear_token(:password_reset_token)
    save!
  end

  def send_email_change_confirmation(address)
    UserMailer.email_change(self, address).deliver
  end

  def email_confirmed?
    active
  end

  def activate
    self.active = true
    clear_token(:confirmation_token)
    save!
  end

  def is_moderator?
    account_status == STATUS_MODERATOR || account_status == STATUS_ADMIN
  end

  def is_admin?
    account_status == STATUS_ADMIN
  end

  def is_spammer?
    account_status == STATUS_SPAM
  end

  def change_password(new_password)
    self.password = new_password
    self.password_confirmation = new_password
    saved = self.save
    UserMailer.password_change(self).deliver if saved
    saved
  end

  # Data sent to the browser for JS interaction
  def to_js
    {
      fullname: self.fullname,
      email: self.email,
      expand_abstracts: self.expand_abstracts
    }.to_json
  end

  # Given an author_identifier, queries arXiv for papers
  # authored by this user and makes corresponding Authorship
  # connections
  def update_authorship!(saving=false)
    url = "http://export.arxiv.org/fb/feed/#{author_identifier}/?format=xml"
    doc = Nokogiri(open(url))
    doc.css('entry id').each do |el|
      uid = el.text.match(/arxiv.org\/abs\/(.+)/)[1]
      if m = uid.match(/(.+)v\d+/) # Strip version if needed
        uid = m[1]
      end
      authorships.where(paper_uid: uid).first_or_create!
    end

    self.papers_count = Authorship.where(user_id: id).count
    self.save! unless saving
  end

  def activity_feed(n=25)
    # Fancy activity query
    # We don't need no denormalization here
    results = execute(%Q{
      SELECT 'scite' AS event, 'paper' AS subject_type, paper_uid AS subject_id, created_at
        FROM scites
        WHERE scites.user_id = ?
        UNION ALL
      SELECT 'subscribe' AS event, 'feed' AS subject_type, feed_uid AS subject_id, created_at
        FROM subscriptions
        WHERE subscriptions.user_id = ?
        UNION ALL
      SELECT 'comment' AS event, 'comment' AS subject_type, id::text AS subject_id, created_at
        FROM comments
        WHERE comments.user_id = ? AND comments.deleted IS FALSE
        UNION ALL
      SELECT 'authorship' AS event, 'paper' AS subject_type, paper_uid AS subject_id, created_at
        FROM authorships
        WHERE authorships.user_id = ?
      ORDER BY created_at DESC
      LIMIT ?
    }, id, id, id, id, n)

    subject_ids = {}

    results.each do |result|
      type = result['subject_type']
      if type == 'comment'
        result['subject_id'] = result['subject_id'].to_i
      end
      subject_ids[type] ||= []
      subject_ids[type] << result['subject_id']
    end

    subjects = {
      'paper' => (map_models :uid, Paper.where(uid: subject_ids['paper'])),
      'feed' => (map_models :uid, Feed.where(uid: subject_ids['feed'])),
      'comment' => (map_models :id, Comment.where(id: subject_ids['comment']).includes(:paper))
    }

    results.map do |result|
      subject = subjects[result['subject_type']][result['subject_id']]

      Activity.new(event: result['event'],
                   created_at: result['created_at'],
                   result['subject_type'] => subject)
    end
  end

  private
    # Generate a random confirmation token in column
    # Also puts the time in self[ column - '_token' + '_sent_at' ] if it exists
    def generate_token(column)
      self[column] = SecureRandom.urlsafe_base64

      column_split = column.to_s.split('_')

      if column_split[-1] == "token"
        sent_at = column_split[0..-2].append("sent_at").join('_').to_sym

        if User.column_names.include? sent_at.to_s
          self[sent_at] = Time.zone.now
        end
      end
    end

    # Clears a generated token
    # Also clears self[ column - '_token' + '_sent_at' ] if it exists
    def clear_token(column)
      self[column] = nil

      column_split = column.to_s.split
      if column_split[-1] == "token"
        sent_at = column_split[0..-2].append("sent_at").join('_').to_sym

        if User.column_names.include? sent_at.to_s
          self[sent_at] = nil
        end
      end
    end
end
