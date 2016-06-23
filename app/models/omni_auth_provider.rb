class OmniAuthProvider

  def initialize(provider_name)
    @provider_name = provider_name
  end

  def available?
    true if app_id && app_secret
  end

  def config
    Rails.application.secrets.omniauth
    .try(:[], AppVersion.domain)
    .try(:[], @provider_name.to_s)
  end

  def app_id
    config.try(:[], 'app_id')
  end

  def app_secret
    config.try(:[], 'app_secret')
  end

  def self.github
    @@github ||= self.new(:github)
  end

  def self.twitter
    @@twitter ||= self.new(:twitter)
  end

  def self.facebook
    @@facebook ||= self.new(:facebook)
  end

  def self.google
    @@google ||= self.new(:google)
  end

  def self.any?
    github.available? || twitter.available? || facebook.available? || google.available?
  end

end