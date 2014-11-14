class StatisticsController < ApplicationController
  
  skip_authorization_check only: [:index]
  
  def index
    authorize! :index, :statistics
  end
  
end