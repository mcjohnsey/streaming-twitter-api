require 'tweetstream'
require 'uri'
require 'json'
require_relative 'stopwatch'
require_relative 'tweet'

DEBUGGING = true
CONFIG_FILE_LOCATION = 'config.json'
config = JSON.parse(File.read(CONFIG_FILE_LOCATION))

def print_debug(debug_string)
  puts debug_string if DEBUGGING
end

very_beginning = Stopwatch.new 'very_beginning'

CONSUMER_KEY = config['CONSUMER_KEY']
CONSUMER_SECRET = config['CONSUMER_SECRET']
ACCESS_TOKEN = config['ACCESS_TOKEN']
ACCESS_TOKEN_SECRET = config['ACCESS_TOKEN_SECRET']

STOP_AFTER_MINUTES = config['STOP_AFTER_MINUTES']
STOP_AFTER_SECONDS = STOP_AFTER_MINUTES * 60

def read_via_tweetstream
  tweets = []

  # start stream gather
  TweetStream.configure do |config|
    config.consumer_key       = CONSUMER_KEY
    config.consumer_secret    = CONSUMER_SECRET
    config.oauth_token        = ACCESS_TOKEN
    config.oauth_token_secret = ACCESS_TOKEN_SECRET
    config.auth_method        = :oauth
  end


  EM.run do
    client = TweetStream::Client.new

    client.on_error do |error|
      print_debug error
    end

    client.sample do |tweet|
      tweets << Tweet.new(tweet.text,tweet.uris.map { |uri|  uri.expanded_url})
      client.stop if tweets.size >= 1000 #stops after a certain amount of tweets collected
    end

    EM::Timer.new(STOP_AFTER_SECONDS) do
      client.stop
    end
  end

  return tweets
end

def print_top_10_domains(tweets)
  print_debug 'Top 10 Domains:'

  # grab all the count hashes from the tweets
  count_hashes = tweets.map{|tweet| tweet.url_count_hash}

  #combine all the hashes together
  consolidated_count_hash = count_hashes.inject{|memo,el| memo.merge(el){|k,old_v,new_v| old_v+new_v}}

  # sort the hash by the value asc
  # pop the last 10
  # reverse it to make it a "Top 10"
  # make it a hash
  # print the results
  consolidated_count_hash.sort_by { |k, v| v }.pop(10).reverse.to_h.each do |host, url_count|
    count = count ? count+1 : 1
    print_debug "##{count} - #{host} - #{url_count}"
  end
end

def print_counts(tweets,seconds_reading_the_stream)
  print_debug "Tweets captured: #{tweets.length}"
  print_debug "Seconds on the stream: #{seconds_reading_the_stream}"
  print_debug "Avg tweets per second #{(tweets.length.to_f / seconds_reading_the_stream.to_f).round(2)}"

  tweets_with_uri_count = tweets.select {|x| x.contains_link?}.length
  print_debug "Count of tweets containing a url: #{tweets_with_uri_count}"
  print_debug "Percent of tweets containing a url: #{(tweets_with_uri_count.to_f / tweets.length.to_f * 100.0).round(2)}%"

  tweets_with_instagram_count = tweets.select{|x|x.contains_instagram_link?}.length
  print_debug "Count of tweets with Instagram links: #{tweets_with_instagram_count}"
  print_debug "Percent of tweets with instagram links: #{(tweets_with_instagram_count.to_f / tweets.length.to_f * 100.0).round(2)}%"

  print_top_10_domains tweets
end

stream_catcher = Stopwatch.new 'stream_catcher'
tweets = read_via_tweetstream
secs_reading_the_stream = stream_catcher.elapsed_time.to_i
print_counts tweets,secs_reading_the_stream

# print_debug("Total seconds elapsed: #{very_beginning.elapsed_time}")
