#!/usr/bin/env ruby
require 'optparse'
require 'uri'
require 'net/http'
require 'openssl'
require 'json'
require 'time'

options = {}
optionparser = OptionParser.new do |opts|
  opts.banner = "Usage: read-hawkular.rb -h <hostname> [options]"

  opts.on("-h", "--hostname=HOSTNAME", "Hawkular server hostname") do |v|
    options[:hostname] = v
  end
  opts.on("-n", "--node=NODE", "Node to query [hosname]") do |v|
    options[:node] = v
  end
  opts.on("-p", "--port=PORT", "Hawkular server port [443]") do |v|
    options[:port] = v.to_i
  end
  opts.on("-s", "--start=START_TIME", "Query start time (e.g 13:45, 1 June 2015 12:42)") do |v|
    options[:start] = Time.parse(v).to_i * 1000
  end
  opts.on("-e", "--end=END_TIME", "Query end time (e.g 13:45, 1 June 2015 12:42)") do |v|
    options[:end] = Time.parse(v).to_i * 1000
  end
  opts.on("-d", "--duration=TIME", "Duration to read in minutes [1]") do |v|
    options[:duration] = v.to_i
  end
  opts.on("-b", "--bearer=BEARER", "The authorization token") do |v|
    options[:bearer] = v
  end
end
optionparser.parse!
if options[:hostname].nil?
  puts optionparser.help
  exit
end

options[:node] ||= options[:hostname]
options[:port] ||= 443
options[:end] ||= Time.now.to_i * 1000
options[:duration] ||= 1
options[:start] ||= options[:end] - options[:duration] * 60 * 1000
options[:bearer] ||= 'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJtYW5hZ2VtZW50LWluZnJhIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6Im1hbmFnZW1lbnQtYWRtaW4tdG9rZW4tcnAxZ3giLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoibWFuYWdlbWVudC1hZG1pbiIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6ImMzODE3NWU5LTM5NGItMTFlNi1iOWFkLTAwMWE0YTIzMTRkNSIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDptYW5hZ2VtZW50LWluZnJhOm1hbmFnZW1lbnQtYWRtaW4ifQ.nORVyramYixUz5_Fg5j-A2FILYnUmPzdHiXWRXfQpdAfaMe-YoKjsZOhCDvaOyoNxjIQ3MTIUU48ZZ8Wk9j-GJUkJhWAU48rFhPi-yw8fv8N11jlx9p2p6wfseLVQt11rmVyAUoTVQLGeo-RIWPyegR1DNVIDW2ciPGeKBiuJKHxDJBS3whuQ2apf-6J75_EfEnCBkhhwKoxvtlGhfPdrhJwy16kmw9p6J0cRvhjr31wZo-NY-YI9SF4JVbQD2Tg08ohSZTjQiehTlv0Fm8MJ4x_4RHmhVnYodUOo6HQoDHjSscJMnwBDC2R-QHFET145aVLhLNVZDpiFivUHcgp3A'

url = URI("https://#{options[:hostname]}:#{options[:port]}/hawkular/metrics/counters/machine%252F#{options[:node]}%252Fnetwork%252Frx/data/?bucketDuration=20s&start=#{options[:start]}&end=#{options[:end]}")

http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE

request = Net::HTTP::Get.new(url)
request["authorization"] = "Bearer #{options[:bearer]}"
request["hawkular-tenant"] = '_system'
request["content-type"] = 'application/json'
request["cache-control"] = 'no-cache'

response = http.request(request)
data = JSON.parse(response.read_body)

puts data
