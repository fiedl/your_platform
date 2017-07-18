concern :HasProfile do

  included do
    include ProfileFields
    include ProfileSections
  end

  def profile
    @profile ||= Profile.new(self)
  end

end