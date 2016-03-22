module Api::V1::Users
  class TitlesController < ApplicationController
    
    def index
      authorize! :autocomplete_title, User
      
      query = params[:term] || params[:query] || ""
      @users = User
        .where("CONCAT(first_name, ' ', last_name) LIKE ?", "%#{query}%")
        .select { |user| can? :read, user }

      render json: @users.map(&:title)
    end
    
  end
end