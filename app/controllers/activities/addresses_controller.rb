#class Changelogs::AddressesController < ApplicationController
#
#  def index
#    activities = PublicActivity::Activity.where(trackable_type: 'ProfileField')
#    profile_field_ids = activities.pluck :trackable_id
#    address_field_ids = ProfileField.where(id: profile_field_ids, type: 'ProfileFields::Address').paginate(page: params[:page]).pluck :id
#    @activities = PublicActivity::Activity.where(trackable_type: 'ProfileField', trackable_id: address_field_ids)
#
#    #binding.pry
#    authorize! :read, @activities
#    render 'activities/index'
#
#  end
#
#end