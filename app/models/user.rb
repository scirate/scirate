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
#

class User < ActiveRecord::Base
  attr_accessible :name, :email, :password, :password_confirmation
  has_secure_password

  has_many :scites, foreign_key: 'sciter_id', dependent: :destroy
  has_many :scited_papers, through: :scites, source: :paper

  before_save :create_remember_token

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

  private

    def create_remember_token
      self.remember_token = SecureRandom.urlsafe_base64
    end
end
