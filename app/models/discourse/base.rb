class Discourse::Base

  def initialize(api_result)
    @api_result = api_result
  end

  def api_result
    @api_result
  end

  def self.api
    api_client
  end

  def self.api_client
    @api_client ||= DiscourseApi::Client.new(discourse_url, api_key, api_username)
  end

  def self.discourse_url
    Rails.application.secrets.discourse_url || raise(RuntimeError, 'secret discourse_url missing')
  end

  def self.api_key
    Rails.application.secrets.discourse_master_api_key
  end

  def self.api_username
    Rails.application.secrets.discourse_user || raise(RuntimeError, 'secret discourse_user missing')
  end

  def self.new_topic_url
    discourse_url
  end

end