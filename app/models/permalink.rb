class Permalink < ActiveRecord::Base
  belongs_to :reference, polymorphic: true
  validates :path, presence: true, uniqueness: true

end
