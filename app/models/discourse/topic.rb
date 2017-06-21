class Discourse::Topic < Discourse::Base

  def id
    api_result['id']
  end

  def title
    api_result['title']
  end

  def url
    "#{self.class.discourse_url}/t/#{title.parameterize}/#{id}"
  end

  def last_posted_at
    api_result['last_posted_at'].to_time
  end

  def last_poster_username
    api_result['last_poster_username']
  end

  def last_poster
    User.find_by_alias last_poster_username
  end

  def self.latest(count = nil)
    api_topics = api.latest_topics
    api_topics = api_topics.first(count) if count
    api_topics.collect do |api_topic|
      self.new(api_topic)
    end
  end

end