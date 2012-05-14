# == Schema Information
#
# Table name: users
#
#  id                     :integer         primary key
#  name                   :string(255)
#  email                  :string(255)
#  remember_token         :string(255)
#  created_at             :timestamp       not null
#  updated_at             :timestamp       not null
#  password_digest        :string(255)
#  scites_count           :integer         default(0)
#  password_reset_token   :string(255)
#  password_reset_sent_at :timestamp
#  confirmation_token     :string(255)
#  active                 :boolean         default(FALSE)
#  comments_count         :integer         default(0)
#  confirmation_sent_at   :timestamp
#  subscriptions_count    :integer         default(0)
#

class User < ActiveRecord::Base
  attr_accessible :name, :email, :password, :password_confirmation
  has_secure_password

  has_many :scites, foreign_key: 'sciter_id', dependent: :destroy
  has_many :scited_papers, through: :scites, source: :paper, order: "identifier DESC"
  has_many :comments, dependent: :destroy, order: "created_at DESC"
  has_many :subscriptions, dependent: :destroy
  has_many :feeds, through: :subscriptions

  before_save { generate_token(:remember_token) }

  validates :name, presence: true, length: { maximum: 50 }

  valid_email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, format: { with: valid_email_regex },
                    uniqueness: { case_sensitive: false }

  validates :password, length: { minimum: 6 }, on: :create

  def scited?(paper)
    scites.find_by_paper_id(paper.id)
  end

  def scite!(paper)
    scites.create!(paper_id: paper.id)
  end

  def unscite!(paper)
    scites.find_by_paper_id(paper.id).destroy
  end

  def subscribed?(feed)
    subscriptions.find_by_feed_id(feed.id)
  end

  def subscribe!(feed)
    subscriptions.create!(feed_id: feed.id)
  end

  def unsubscribe!(feed)
    subscriptions.find_by_feed_id(feed.id).destroy
  end

  def has_subscriptions?
    subscriptions.size > 0
  end

  def feed
    Paper.from_feeds_subscribed_by(self)
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

  def active?
    active
  end

  def activate
    self.active = true
    clear_token(:confirmation_token)
    save!
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
