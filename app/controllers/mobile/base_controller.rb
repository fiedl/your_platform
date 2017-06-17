class Mobile::BaseController < ApplicationController

  expose :beta, -> { Mobile::BaseController.mobile_beta }

  def self.mobile_beta
    Beta.find_by key: 'vademecum-app'
  end

  def authorize_miniprofiler
    # Do not use mini profiler in mobile view for now.
    # Rack::MiniProfiler.authorize_request if can? :use, Rack::MiniProfiler
  end

end