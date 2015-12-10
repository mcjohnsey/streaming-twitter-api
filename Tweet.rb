class Tweet
  def initialize(text,uris)
    @text = text
    @urls = uris
  end

  def contains_link?
    !@urls.empty?
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
end
