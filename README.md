# Streaming Twitter API Tire Kicker
This project uses TweetStream's library to query the public sample stream (aka "garden hose") and gather statistics.

## Example Output
```
Tweets captured: 28387
Seconds on the stream: 600
Avg tweets per second 47.31
Count of tweets containing a url: 6828
Percent of tweets containing a url: 24.05%
Count of tweets with Instagram links: 354
Percent of tweets with instagram links: 1.25%
Top 10 Domains:
#1 - twitter.com - 1509
#1 - bit.ly - 652
#1 - goo.gl - 589
#1 - fb.me - 382
#1 - www.instagram.com - 354
#1 - youtu.be - 258
#1 - vine.co - 220
#1 - ift.tt - 160
#1 - ow.ly - 152
#1 - dlvr.it - 122
```

## Gems Used
```ruby
gem install eventmachine #https://github.com/eventmachine/eventmachine
```

## Config File
Please add a `config.json` file to the root that looks like the example below.
```json
{
  "CONSUMER_KEY": "ABCDEF123456",
  "CONSUMER_SECRET": "1234567",
  "ACCESS_TOKEN": "abcdef12345",
  "ACCESS_TOKEN_SECRET": "98765",
  "STOP_AFTER_MINUTES": 0.1,
  "GARDENHOSE_API_URL": "https://stream.twitter.com/1.1/statuses/sample.json",
  "DEBUGGING": true
}
```
