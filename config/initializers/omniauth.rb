Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, ENV['TWITTER_API_KEY'], ENV['TWITTER_API_KEY_SECRET'], callback_url: ENV['HOST'] + "/auth/twitter/callback"
end