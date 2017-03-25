module ResourceNavHelper

  def show_resource_nav?
    resource_centred_layout? && current_navable.try(:in_intranet?)
  end

end