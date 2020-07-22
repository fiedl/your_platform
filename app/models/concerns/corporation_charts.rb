concern :CorporationCharts do

  def number_of_members_chart
    Charts::NumberOfMembers::Corporation.new(group: self)
  end

end