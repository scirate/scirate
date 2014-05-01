class AuthLink < ActiveRecord::Base
  def self.from_omniauth(auth, user=nil)
    where(auth.slice(:provider, :uid)).first_or_initialize.tap do |link|
      link.provider = auth.provider
      link.uid = auth.uid
      link.oauth_token = auth.credentials.token
      link.oauth_expires_at = Time.at(auth.credentials.expires_at)

      if user.nil?
        user = User.new
        user.email = auth.info.email
        user.fullname = auth.info.name
        user.username = User.default_username(auth.info.name)
        user.save!
      end

      link.user = user
    end
  end
end
