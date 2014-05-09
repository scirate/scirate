# == Schema Information
#
# Table name: auth_links
#
#  id               :integer          not null, primary key
#  provider         :string(255)      not null
#  uid              :string(255)      not null
#  oauth_token      :string(255)      not null
#  oauth_expires_at :datetime         not null
#  user_id          :integer          not null
#  created_at       :datetime
#  updated_at       :datetime
#

class AuthLink < ActiveRecord::Base
  belongs_to :user

  serialize :auth # Keep around the original auth hash from provider

  def self.from_omniauth(auth)
    where(auth.slice(:provider, :uid)).first_or_initialize.tap do |link|
      link.provider = auth.provider
      link.uid = auth.uid
      link.oauth_token = auth.credentials.token
      link.oauth_expires_at = Time.at(auth.credentials.expires_at)
      link.auth = auth
    end
  end

  def create_user!
    User.new.tap do |user|
      user.email = auth.info.email
      user.fullname = auth.info.name
      user.username = User.default_username(auth.info.name)
      user.active = true # Don't need to ask for email confirmation in oauth
      user.auth_links = [self]
      user.save!
    end
  end
end
