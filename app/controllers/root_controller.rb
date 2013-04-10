class RootController < ApplicationController

  skip_authorization_check

  def index
    @page = Page.find_intranet_root

    unauthorized! if cannot? :read, @page
    @navable = @page
  end
end
