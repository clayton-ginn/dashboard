require 'net/http'
require 'json'

SCHEDULER.every '10m', :first_in => 0 do |job|  
  repo_id = "52f3fbd3695680658400ad53"
  api_token = "09c6a2c00ba904607c775559a00eafd6846f8cdf"
  
  uri = URI.parse("https://codeclimate.com/api/repos/#{repo_id}")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  request = Net::HTTP::Get.new(uri.request_uri)
  request.set_form_data({api_token: api_token})
  response = http.request(request)
  stats = JSON.parse(response.body)
  current_gpa = stats['last_snapshot']['gpa'].to_f
  last_gpa = stats['previous_snapshot']['gpa'].to_f
  send_event("code-climate", {current: current_gpa, last: last_gpa})
end