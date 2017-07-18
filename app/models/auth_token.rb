class AuthToken < ApplicationRecord
  has_secure_token :token
  belongs_to :user
  belongs_to :resource, polymorphic: true
  belongs_to :post

  validates :token, presence: true, uniqueness: true, length: { minimum: 20 }
  validates :user, presence: true
  validates :resource, presence: true

  def self.create(options = {})
    super(options.except(:user, :resource, :post, :token)) do |auth_token|
      auth_token.regenerate_token
      auth_token.user = options[:user] || raise('no user given.')
      auth_token.resource = options[:resource] || raise('no resource given. this is the record the user shall be given access to.')
      auth_token.post = options[:post]
    end
  end

end
