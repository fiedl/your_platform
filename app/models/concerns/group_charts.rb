concern :GroupCharts do

  def number_of_members_chart
    Charts::NumberOfMembers::Group.new(group: self)
  end

end