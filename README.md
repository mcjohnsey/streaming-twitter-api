# Streaming Twitter API Tire Kicker
This project uses TweetStream's library to query the public sample stream (aka "garden hose") and gather statistics.

## Gems Used
```ruby
gem install tweetstream #https://github.com/tweetstream/tweetstream
gem install longurl #https://github.com/jakimowicz/longurl
```

## Config File
Please add a `config.json` file to the root that looks like the example below.
```json
{
  "CONSUMER_KEY":"ABCDEF123456",
  "CONSUMER_SECRET":"123456",
  "ACCESS_TOKEN":"abc123456",
  "ACCESS_TOKEN_SECRET":"98765",
  "STOP_AFTER_MINUTES":0.5,
  "NUM_OF_THREADS":16
}
```
