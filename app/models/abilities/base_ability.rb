class Abilities::BaseAbility
  include CanCan::Ability

  def initialize(user, options = {})

    # Preview other roles.
    # Attention: Check outside whether the user's role allowes that preview!
    # Currently, this is done in ApplicationController#current_ability.
    #
    @view_as = (options[:preview_as] || options[:view_as]).try(:to_sym)
    @view_as = nil if @view_as.in? [:full_member]

    # There are two kinds of token: `User#token` and `AuthToken#token`,
    # which are both handled by the same parameter:
    @token = options[:token]
    @user_by_auth_token = options[:user_by_auth_token]
    @user = user || @user_by_auth_token

    # When the system is in read-only mode, write abilities are disallowed.
    @read_only_mode = options[:read_only_mode]

    rights_for_everyone
    if @user_by_auth_token.try(:account).present?
      rights_for_auth_token_users
    elsif user.try(:account).present? && user.has_flag?(:dummy)
      rights_for_dummy_users
    elsif user.try(:account).present?
      rights_for_signed_in_users
      rights_for_beta_testers if user.beta_tester?
      rights_for_developers if user.developer?
      rights_for_global_officers if view_as?([:global_officer, :officer, :admin]) && user.is_global_officer?
      rights_for_local_officers if view_as?([:officer, :admin])
      if view_as?(:admin) && user.admin_of_anything?
        rights_for_local_admins
        rights_for_page_admins
      end
      rights_for_global_admins if view_as?(:global_admin) && user.global_admin?
    end

  end

  def rights_for_everyone
  end

  def rights_for_auth_token_users
  end

  def rights_for_signed_in_users
  end

  def rights_for_beta_testers
  end

  def rights_for_developers
  end

  def rights_for_dummy_users
  end

  def rights_for_global_officers
  end

  def rights_for_local_officers
  end

  def rights_for_local_admins
  end

  def rights_for_page_admins
  end

  def rights_for_global_admins
  end

  def view_as?(role_or_roles)
    roles = role_or_roles.kind_of?(Array) ? role_or_roles : [role_or_roles]
    @view_as.blank? || @view_as.in?(roles)
  end
  def token
    @token
  end
  def auth_token
    @auth_token ||= AuthToken.where(token: token).first if @user_by_auth_token
  end
  def read_only_mode?
    @read_only_mode
  end
  def user
    @user
  end

end