concern :HasPermalinks do

  included do
    has_many :permalinks, as: :reference, dependent: :destroy

  end

  def permalink_path
    "/#{permalinks.first.path}" if permalinks.any?
  end

end