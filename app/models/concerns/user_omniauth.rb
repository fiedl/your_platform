concern :UserOmniauth do
  class_methods do

    def from_omniauth(auth)
      case auth.provider
      when 'github', 'twitter', 'google_oauth2', 'facebook'
        User.find_by_email auth.info.email if auth.info.email.present?
      else
        binding.pry if Rails.env.development?
        raise RuntimeError, "Omniauth provider #{auth.provider} not handled, yet."
      end
    end
  end

end