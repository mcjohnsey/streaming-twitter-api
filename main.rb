require 'tweetstream'
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

# start stream gather
TweetStream.configure do |config|
  config.consumer_key       = CONSUMER_KEY
  config.consumer_secret    = CONSUMER_SECRET
  config.oauth_token        = ACCESS_TOKEN
  config.oauth_token_secret = ACCESS_TOKEN_SECRET
  config.auth_method        = :oauth
end

statuses = []

stream_catcher = Stopwatch.new('stream_catcher')
EM.run do
  client = TweetStream::Client.new

  client.on_error do |error|
    print_debug(error)
  end

  client.sample do |tweet|
    statuses << tweet
    # client.stop if @statuses.size >= 100000 #stops after a certain amount of tweets collected
  end

  EM::Timer.new(STOP_AFTER_SECONDS) do
    client.stop
  end
end

secs_reading_the_stream = stream_catcher.elapsed_time.to_i

url_processor = Stopwatch.new('url_processor')

url_count_h = Hash.new(0)

tweets_with_uri_counts = 0
tweets_with_instagram_links = 0

statuses.each do |status|
  if status.uris?
    tweets_with_uri_counts += 1
    tweet_contains_instagram = false

    status.uris.each do |url|
      url_host = url.expanded_url.host
      tweet_contains_instagram = url_host == 'www.instagram.com'
      url_count_h[url_host] += 1
    end

    tweets_with_instagram_links += 1 if tweet_contains_instagram
  end
end

# print_debug("Url Processor elapsed seconds: #{url_processor.elapsed_time}")

print_debug("Tweets captured: #{statuses.length}")
# print_debug("Seconds on the stream: #{secs_reading_the_stream}")
print_debug("Avg tweets per second #{(statuses.length.to_f / STOP_AFTER_SECONDS.to_f).round(2)}")
print_debug("Count of tweets containing a url: #{tweets_with_uri_counts}")
print_debug("Percent of tweets containing a url: #{(tweets_with_uri_counts.to_f / statuses.length.to_f * 100.0).round(2)}%")
print_debug("Tweets with instagram links: #{tweets_with_instagram_links}")
print_debug("Percent of tweets with instagram links: #{(tweets_with_instagram_links.to_f / statuses.length.to_f * 100.0).round(2)}%")

print_debug('Top 10 Domains:')
count = 0
url_count_h.sort_by { |_k, v| v }.pop(10).reverse.to_h.each do |k, v|
  count += 1
  print_debug("##{count} - #{k} - #{v}")
end

# print_debug("Total seconds elapsed: #{very_beginning.elapsed_time}")
