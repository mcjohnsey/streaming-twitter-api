require 'uri'
class Tweet
  def initialize(text,urls)
    @text = text
    @urls = urls
  end

  def contains_link?
    !@urls.empty?
  end

  def contains_multiple_links?
    contains_link? and @urls.count>1
  end

  def contains_instagram_link?
      @urls.map { |url| url.host}.include? 'www.instagram.com'
  end

  def url_count_hash
    url_count_h = Hash.new(0)
    @urls.each do |url|
      url_count_h[url.host] += 1
    end
    url_count_h
  end

  def to_s
    "#{@text}\nUris:\n#{@urls.each {|x| x.to_s}}"
  end

  def self.from_json(json)
    text = json['text']
    urls = []

    json['entities']['urls'].each do |url|
      urls << URI(url['expanded_url'])
    end

    return Tweet.new(text,urls)
  end
end
