Hmrc.configure do |config|
  config.base_url = ENV["HMRC_API_BASE_URL"]
  config.client_id = ENV["HMRC_API_CLIENT_ID"]
  config.client_secret = ENV["HMRC_API_CLIENT_SECRET"]
end
