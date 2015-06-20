class EmojisController < ApplicationController
  skip_authorization_check only: 'index'
  
  
  def index
    # https://github.com/github/gemoji
    
    @emoji_keys = Rails.cache.fetch("emoji_keys") {
      gemojis = Emoji.all # {aliases: [], tags: [], unicode_keys: []}
      emoji_keys = gemojis.collect { |gemoji| gemoji.aliases }.flatten
    }
        
    query = params[:query]
    @emoji_keys = @emoji_keys.select { |key| key.include? query }
    @emoji_keys = @emoji_keys.take(params[:limit].to_i) if params[:limit].present?
    
    @emojis = @emoji_keys.collect do |key|
      gemoji = Emoji.find_by_alias(key)
      {
        key: key,
        image_path: view_context.image_path("emoji/#{gemoji.image_filename}"),
        image_tag: %(<img alt="#{key}" src="#{view_context.image_path("emoji/#{gemoji.image_filename}")}" style="vertical-align:middle" width="20" height="20" />)
      }
    end
        
    render json: @emojis
  end
  
end