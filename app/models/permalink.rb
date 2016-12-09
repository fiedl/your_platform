class Permalink < ActiveRecord::Base
  belongs_to :reference, polymorphic: true
  validates :path, presence: true, uniqueness: {scope: :host}

  scope :for_host, -> (host) { where(host: [nil, host]) }

end
