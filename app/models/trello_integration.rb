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

  concerning :BotUser do
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

  concerning :FeaturesBoard do
    def features_board
      board_id = Setting.trello_board_url_for_features.split("/")[4]
      Trello::Board.find(board_id)
    end

    def features_doing_lists
      Rails.cache.fetch "TrelloIntegration#features_doing_lists", expires_in: 14.days do
        features_board.lists.select { |list| list.name.include? "Doing" }
      end
    end

    def features_doing_cards
      Rails.cache.fetch "TrelloIntegration#features_doing_cards", expires_in: 15.minutes do
        features_doing_lists.to_a.collect { |list| list.cards.target.to_a }.flatten
      end
    end
  end

end