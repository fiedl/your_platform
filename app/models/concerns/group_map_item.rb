concern :GroupMapItem do

  def map_item
    MapItem.from_group(self)
  end

end