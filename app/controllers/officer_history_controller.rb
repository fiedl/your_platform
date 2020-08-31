class OfficerHistoryController < ApplicationController

  expose :group
  expose :memberships, -> { group.memberships.with_past.order(valid_from: :desc) }

  def index
    authorize! :read, group

  end

end