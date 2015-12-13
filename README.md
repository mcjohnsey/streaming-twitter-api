# Streaming Twitter API Tire Kicker
This project uses TweetStream's library to query the public sample stream (aka "garden hose") and gather statistics.

## Example Output
```
Tweets captured: 29028
Avg tweets per second 48.38
Count of tweets containing a url: 6592
Percent of tweets containing a url: 22.71%
Tweets with instagram links: 201
Percent of tweets with instagram links: 0.69%
Top 10 Domains:
#1 - twitter.com - 1475
#2 - bit.ly - 614
#3 - goo.gl - 450
#4 - fb.me - 273
#5 - vine.co - 221
#6 - youtu.be - 207
#7 - www.instagram.com - 201
#8 - ift.tt - 180
#9 - dlvr.it - 144
#10 - www.youtube.com - 86
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
