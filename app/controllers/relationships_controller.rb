class RelationshipsController < ApplicationController
  respond_to :json

  def destroy
  end

  def update
    @relationship = Relationship.find params[ :id ]
    @relationship.update_attributes params[ :relationship ]
    respond_with @relationship
  end
end
