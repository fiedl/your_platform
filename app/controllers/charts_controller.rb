class ChartsController < ApplicationController

  def index
    authorize! :index, :charts
  end

  private

  def corporations
    @corporations ||= if params[:corporation] == 'none'
      corporations = []
    elsif filter_corporation = params[:corporation]
      corporations = Corporation.where(token: filter_corporation)
      corporations = Corporation.all if corporations.none?
    else
      corporations = Corporation.all
    end

  end

end