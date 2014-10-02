require 'google/api_client'
require 'date'

# Update these to match your own apps credentials
service_account_email = ENV['GOOGLE_SERVICE_ACCOUNT_EMAIL'] # Email of service account
service_account_email = "704166384458-ergprn4acccr3ola05d8ev6i7hq5s70e@developer.gserviceaccount.com" # Email of service account
key_file = File.expand_path(File.join(File.dirname(__FILE__), "../config/Preferral-c453eb0c8544.p12")) # File containing your private key
key_secret = 'notasecret' # Password to unlock private key
# profile_id = ENV['GOOGLE_ANALYTICS_PROFILE_ID'] # Analytics profile ID.
profile_id = "47672801"

ENV['GOOGLE_APPLICATION_NAME'] = "WorkMeIn - Preferral"

# Get the Google API client
client = Google::APIClient.new(
  :application_name => ENV['GOOGLE_APPLICATION_NAME'],
  :application_version => '0.01'
)

visitors = []

# Load your credentials for the service account
key = Google::APIClient::KeyUtils.load_from_pkcs12(key_file, key_secret)
client.authorization = Signet::OAuth2::Client.new(
  :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
  :audience => 'https://accounts.google.com/o/oauth2/token',
  :scope => 'https://www.googleapis.com/auth/analytics.readonly',
  :issuer => service_account_email,
  :signing_key => key)

# Start the scheduler
SCHEDULER.every '5s', :first_in => 0 do

  # Request a token for our service account
  client.authorization.fetch_access_token!

  # Get the analytics API
  analytics = client.discovered_api('analytics','v3')

  # Execute the query
  response = client.execute(:api_method => analytics.data.realtime.get, :parameters => {
    'ids' => "ga:" + profile_id,
    'metrics' => "ga:activeVisitors",
  })

  # puts response.data
  # binding.pry

  # visitors << { x: Time.now.to_i, y: response.data.rows } # getting insufficientPermissions error...
  visitors << { x: Time.now.to_i, y: rand(90..140) }

  # Update the dashboard
  # puts "\n~~~~~~~~~~"
  # puts visitors
  # puts "~~~~~~~~~~~~\n"
  send_event('visitor_count_real_time', points: visitors)
end