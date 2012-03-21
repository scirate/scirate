# == Schema Information
#
# Table name: users
#
#  id              :integer         not null, primary key
#  name            :string(255)
#  email           :string(255)
#  remember_token  :string(255)
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#  password_digest :string(255)
#  scites_count    :integer         default(0)
#

class User < ActiveRecord::Base
  attr_accessible :name, :email, :password, :password_confirmation
  has_secure_password

  has_many :scites, foreign_key: 'sciter_id', dependent: :destroy
  has_many :scited_papers, through: :scites, source: :paper

  before_save { generate_token(:remember_token) }

  validates :name, presence: true, length: { maximum: 50 }

  valid_email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, format: { with: valid_email_regex },
                    uniqueness: { case_sensitive: false }
  
  validates :password, length: { minimum: 6 }

  def scited?(paper)
    scites.find_by_paper_id(paper.id)
  end

  def scite!(paper)
    scites.create!(paper_id: paper.id)
  end

  def unscite!(paper)
    scites.find_by_paper_id(paper.id).destroy
  end

  def send_signup_confirmation
    generate_token(:confirmation_token)
    save!(validate: false)
    UserMailer.signup_confirmation(self).deliver
  end

  def send_password_reset
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    save!(validate: false)
    UserMailer.password_reset(self).deliver
  end

  def active?
    self.active
  end

  private

    def generate_token(column)
      begin
        self[column] = SecureRandom.urlsafe_base64
      end while User.exists?(column => self[column])
    end
end
