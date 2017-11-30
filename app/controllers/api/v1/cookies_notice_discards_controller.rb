class Api::V1::CookiesNoticeDiscardsController < ApplicationController

  def create
    authorize! :discard, :cookies_notice

    discard_cookies_notice
  end

end