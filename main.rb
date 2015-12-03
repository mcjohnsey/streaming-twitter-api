require 'tweetstream'
require 'longurl'
require 'uri'
require 'json'
require 'parallel'
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
NUM_OF_THREADS = config['NUM_OF_THREADS']


STOP_AFTER_MINUTES = config['STOP_AFTER_MINUTES']
STOP_AFTER_SECONDS = STOP_AFTER_MINUTES * 60


# start stream gather
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

secs_reading_the_stream = stream_catcher.elapsed_time

url_processor = Stopwatch.new('url_processor')
@urls = []

tweets_with_uri_counts = 0

@statuses.each do |x|
  # push all the URI objects on to the url list
  if x.uris?
    tweets_with_uri_counts += 1
    x.uris.each {|url| @urls<<url.url}
  end
end

@long_urls = []
@url_count_h = Hash.new(0)

Parallel.each(@urls, :in_threads => NUM_OF_THREADS) do |url|
  long_url = LongURL.expand(url.to_s) rescue longurl = url.to_s
  @url_count_h[URI.parse(long_url).host] +=1
end

print_debug("Url Processor elapsed seconds: #{url_processor.elapsed_time}")

print_debug("Tweets captured: #{@statuses.length}")
print_debug("Seconds on the stream: #{secs_reading_the_stream}")
print_debug("Count of tweets containing a url: #{tweets_with_uri_counts}")
print_debug("Urls captured: #{@urls.length}")
print_debug("Tweets containing Instagram links: #{@url_count_h['www.instagram.com']}")
top_10 = @url_count_h.sort_by{|k,v| v}.pop(10).reverse.to_h

# print_debug(top_10)
print_debug("Top 10 Domains:")
count = 0
top_10.each do |k,v|
  count += 1
  print_debug("##{count} - #{k} - #{v}")
end


print_debug("Total seconds elapsed: #{very_beginning.elapsed_time}")
