class MyProfileController < ApplicationController

  expose :user, -> { current_user }

  def show
    authorize! :read, user
    @user = user # for legacy view partials

    set_current_title "Mein Profil"
    set_current_navable user
    set_current_tab :contacts

    render "users/show"
  end

end