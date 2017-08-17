# This controller adds authorization to masquerade.
#
# How does the system know of this controller?
# In `config/routes.rb`, the controller has to be specified:
#
#     devise_for :user_accounts, controllers: {
#       masquerades: 'user_account_masquerades'
#     }
#
class UserAccountMasqueradesController < Devise::MasqueradesController

  expose :user_account
  expose :user, -> { user_account.user }

  def show
    authorize! :use, :masquerade
    authorize! :masquerade_as, user
    super
  end

  protected

  # Without specifying the session key explicitly,
  # masquerade does not set the same session key which is used
  # when checking whether this is a masqueraded session.
  # I.e. the "you are masquerading as user ..." would not
  # be shown.
  #
  # This issue has been introduced in masquerade 0.5.3.
  #
  def session_key
    'devise_masquerade_user_account'
  end

end