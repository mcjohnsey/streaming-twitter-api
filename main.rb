require 'json'
require 'em-http'
require 'em-http/middleware/oauth'
require_relative 'stopwatch'
require_relative 'tweet'

CONFIG_FILE_LOCATION = 'config.json'.freeze
config = JSON.parse(File.read(CONFIG_FILE_LOCATION))

DEBUGGING = config['DEBUGGING']

AUTH = {
  consumer_key: config['CONSUMER_KEY'],
  consumer_secret: config['CONSUMER_SECRET'],
  access_token: config['ACCESS_TOKEN'],
  access_token_secret: config['ACCESS_TOKEN_SECRET']
}.freeze

TWITTER_SAMPLE_URL = config['GARDENHOSE_API_URL']
STOP_AFTER_MINUTES = config['STOP_AFTER_MINUTES']

STOP_AFTER_SECONDS = STOP_AFTER_MINUTES * 60

def print_debug(debug_string)
  puts debug_string if DEBUGGING
end

def print_top_10_domains(tweets)
  print_debug 'Top 10 Domains:'

  # grab all the count hashes from the tweets
  count_hashes = tweets.map(&:url_count_hash)

  # combine all the hashes together
  consolidated_count_hash = count_hashes.inject do |a, e|
    a.merge(e) { |_k, old_v, new_v| old_v + new_v }
  end

  # sort the hash by the value asc
  # pop the last 10
  # reverse it to make it a "Top 10"
  # make it a hash
  # print the results
  count = 0
  consolidated_count_hash.sort_by { |_k, v| v }.pop(10).reverse.to_h.each do |host, url_count|
    count += 1
    print_debug "##{count} - #{host} - #{url_count}"
  end
end

def print_stats(tweets, seconds_reading_the_stream)
  print_debug "Tweets captured: #{tweets.length}"
  print_debug "Seconds on the stream: #{seconds_reading_the_stream}"
  print_debug "Avg tweets per second #{(tweets.length.to_f / seconds_reading_the_stream.to_f).round(2)}"

  tweets_with_uri_count = tweets.count(&:contains_link?)
  print_debug "Count of tweets containing a url: #{tweets_with_uri_count}"
  print_debug "Percent of tweets containing a url: #{(tweets_with_uri_count.to_f / tweets.length.to_f * 100.0).round(2)}%"

  tweets_with_instagram_count = tweets.count(&:contains_instagram_link?)
  print_debug "Count of tweets with Instagram links: #{tweets_with_instagram_count}"
  print_debug "Percent of tweets with instagram links: #{(tweets_with_instagram_count.to_f / tweets.length.to_f * 100.0).round(2)}%"

  print_top_10_domains tweets
end

def read_tweets_from_stream(stream_url, auth_h, stop_after_seconds, request_options = {})
  fail ArgumentError, 'Required to provide a stream handler block.' unless block_given?
  fail ArugmentError, 'Need a stream_url' if stream_url.nil?
  fail ArugmentError, 'Need a stop_after_seconds' if stop_after_seconds.nil?

  EM.run do
    # sign the request with OAuth credentials
    conn = EM::HttpRequest.new(stream_url)
    conn.use EM::Middleware::OAuth, auth_h
    puts "Jumping on the wave for #{stop_after_seconds} seconds"
    http = conn.get(request_options)

    http.callback do
      unless http.response_header.status == 200
        puts "Call failed with #{http.response_header.status}"
      end
    end

    http.stream do |chunk|
      yield chunk
    end

    EM::Timer.new(stop_after_seconds) do
      EM.stop
    end
  end
end

def read_via_direct_json
  tweets = []
  stream = ''
  new_line_regex = /.+\r\n/

  read_tweets_from_stream(TWITTER_SAMPLE_URL, AUTH, STOP_AFTER_SECONDS) do |chunk|
    stream += chunk
    while response = stream.slice!(new_line_regex)
      tweet = JSON.parse(response)
      if tweet['text'] # just grab responses with tweets (excludes things like deletes)
        tweets << Tweet.from_json(tweet)
        puts "Grabbed #{tweets.length} so far" if tweets.length % 50 == 0
      end
    end
  end

  tweets
end

def programming_problem
  stream_catcher = Stopwatch.new 'Time on the stream'
  tweets = read_via_direct_json
  secs_reading_the_stream = stream_catcher.elapsed_seconds
  print_stats tweets, secs_reading_the_stream
end

programming_problem
