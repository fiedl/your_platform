class RelationshipsController < ApplicationController
  respond_to :json

  def new
    @relationship = Relationship.new
  end

  def create
    @relationship = Relationship.create( params[ :relationship ] )    
  end

  def destroy
    @relationship = Relationship.find( params[ :id ] )
    @relationship.destroy
  end

  def update
    @relationship = Relationship.find params[ :id ]
    @relationship.update_attributes params[ :relationship ]
    respond_with @relationship
  end
end
