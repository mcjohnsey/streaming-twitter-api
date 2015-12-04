# Streaming Twitter API Tire Kicker
This project uses TweetStream's library to query the public sample stream (aka "garden hose") and gather statistics.

## Example Output
```
Tweets captured: 29588
Count of tweets containing a url: 6897
Percent of tweets containing a url: 23.31%
Tweets with instagram links: 218
Percent of tweets with instagram links: 0.74%
Top 10 Domains:
#1 - twitter.com - 1436
#2 - bit.ly - 817
#3 - goo.gl - 465
#4 - fb.me - 359
#5 - vine.co - 280
#6 - www.instagram.com - 218
#7 - youtu.be - 218
#8 - ift.tt - 181
#9 - dlvr.it - 149
#10 - ow.ly - 119
```

## Gems Used
```ruby
gem install tweetstream #https://github.com/tweetstream/tweetstream
```

## Config File
Please add a `config.json` file to the root that looks like the example below.
```json
{
  "CONSUMER_KEY":"ABCDEF123456",
  "CONSUMER_SECRET":"1234567",
  "ACCESS_TOKEN":"abcdef12345",
  "ACCESS_TOKEN_SECRET":"98765",
  "STOP_AFTER_MINUTES":0.10
}
```
## TODO
1. Read this https://blog.engineyard.com/2013/ruby-concurrency
1. Read this http://www.toptal.com/ruby/ruby-concurrency-and-parallelism-a-practical-primer
