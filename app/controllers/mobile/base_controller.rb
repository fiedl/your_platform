class Mobile::BaseController < ApplicationController

  expose :beta, -> { Mobile::BaseController.mobile_beta }

  def self.mobile_beta
    Beta.find_by key: 'vademecum-app'
  end

end