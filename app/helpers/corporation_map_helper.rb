module CorporationMapHelper

  def corporation_map_items
    @corporation_map_items ||= MapItem.from_corporations.select { |map_item| map_item.longitude.present? }
  end

end