class Permalink < ActiveRecord::Base
  belongs_to :reference, polymorphic: true
  validates :path, presence: true

  validates :path, uniqueness: true, if: Proc.new { |permalink| not permalink.host.present? }
  validates :path, uniqueness: true, if: Proc.new { |permalink| Permalink.where(host: nil, path: permalink.path).any? }
  validates :path, uniqueness: {scope: :host}

  scope :for_host, -> (host) { where(host: [nil, host]) }

end
