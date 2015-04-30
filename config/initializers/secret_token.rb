Rails.application.config.secret_key_base ||= Rails.application.secrets.secret_key_base
Rails.application.config.secret_key ||= Rails.application.config.secret_key_base