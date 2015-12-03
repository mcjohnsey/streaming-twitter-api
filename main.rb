require 'tweetstream'
require 'longurl'
require 'uri'
require 'json'
require_relative 'stopwatch'

DEBUGGING = true
CONFIG_FILE_LOCATION = 'config.json'
config = JSON.parse(File.read(CONFIG_FILE_LOCATION))


def print_debug(debug_string)
  puts debug_string if DEBUGGING
end

very_beginning = Stopwatch.new('very_beginning')

CONSUMER_KEY = config['CONSUMER_KEY']
CONSUMER_SECRET = config['CONSUMER_SECRET']
ACCESS_TOKEN = config['ACCESS_TOKEN']
ACCESS_TOKEN_SECRET = config['ACCESS_TOKEN_SECRET']

STOP_AFTER_MINUTES = config['STOP_AFTER_MINUTES']
STOP_AFTER_SECONDS = STOP_AFTER_MINUTES * 60

TweetStream.configure do |config|
  config.consumer_key       = CONSUMER_KEY
  config.consumer_secret    = CONSUMER_SECRET
  config.oauth_token        = ACCESS_TOKEN
  config.oauth_token_secret = ACCESS_TOKEN_SECRET
  config.auth_method        = :oauth
end

@statuses  = []

stream_catcher = Stopwatch.new('stream_catcher')
EM.run do
  client = TweetStream::Client.new

  client.on_error do |error|
    print_debug(error)
  end

  client.sample do |tweet|
    @statuses << tweet
    # client.stop if @statuses.size >= 100000
  end

  EM::Timer.new(STOP_AFTER_SECONDS) do
    client.stop
  end
end

print_debug(stream_catcher.elapsed_time)

print_debug("Statuses captured: #{@statuses.length}")

url_processor = Stopwatch.new('url_processor')
@urls = []
@statuses.each do |x|
  # push all the URI objects on to the url list
  x.uris.each {|url| @urls<<url.url} if x.uris?
end

puts "Urls captured: #{@urls.length}"
count = 0
@urls.each do |url|
  count += 1
  longurl = LongURL.expand(url.to_s) rescue longurl = url.to_s
  # puts url.host
  print_debug("##{count} #{URI.parse(longurl).host}")
  # LongURL.expand(url.url.to_s) rescue puts url.url.to_s
end

print_debug(url_processor.elapsed_time)
print_debug(very_beginning.elapsed_time)
