concern :UserOmniauth do
  class_methods do

    def from_omniauth(auth)
      case auth.provider
      when 'github'
        User.find_by_email auth.info.email if auth.info.email.present?
      else
        raise "Omniauth provider not handled, yet. " + auth.to_s
      end
    end
  end

end