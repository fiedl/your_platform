concern :CorporationCaching do

  included do
    cache :status_group_ids
  end

end