class RootController < ApplicationController
  def index
    @navable = Page.find_intranet_root
  end
end
