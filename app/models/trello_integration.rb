class TrelloIntegration

  def initialize
    begin
      Trello.configure do |config|
        config.developer_public_key = trello_bot_public_key
        config.member_token = trello_bot_auth_token
      end
      @connected = true
    rescue
      @connected = false
    end
  end

  def connected?
    @connected
  end

  def trello_bot_public_key
    Setting.trello_bot_public_key
  end

  def trello_bot_auth_token
    Setting.trello_bot_auth_token
  end

  def trello_user
    begin
      Trello::Member.find('me')
    rescue
      nil
    end
  end

  def user_name
    trello_user.try(:username)
  end

  def avatar_url
    trello_user.try(:avatar_url)
  end

end