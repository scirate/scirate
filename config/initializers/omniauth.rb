Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, Settings::GOOGLE_CLIENT_ID, Settings::GOOGLE_CLIENT_SECRET
end
