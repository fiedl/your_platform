class RelationshipsController < ApplicationController

  load_and_authorize_resource


  respond_to :json

  def new
    @relationship = Relationship.new
  end

  def create
    @relationship = Relationship.create( params[ :relationship ] )    
  end

  def destroy
    @relationship.destroy
  end

  def update
    @relationship.update_attributes params[ :relationship ]
    respond_with @relationship
  end
end
