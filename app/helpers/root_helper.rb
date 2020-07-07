module RootHelper

  def groups_for_root_charts
    current_user.corporations + [Group.alle_aktiven, Group.alle_wingolfiten]
  end

  def apexchart_number_of_members(group:)
    years = (2014..(Time.zone.now.year)).to_a
    data_points = years.collect { |year| group.memberships.at_time(Date.today.end_of_year.change(year: year)).count }

    content_tag(:apexchart, "",
      type: 'area',
      ':options': {
        grid: {
          show: false,
          padding: {
            left: 0,
            top: 0,
            bottom: 0,
            right: 0
          }
        },
        xaxis: {
          labels: {show: false},
          categories: years,
          tooltip: {enabled: false}
        },
        yaxis: {
          show: false,
          #min: 0
        },
        chart: {
          toolbar: {show: false},
          animations: {enabled: false},
          zoom: {enabled: false},
          parentHeightOffset: 0,
          sparkline: {enabled: true}
        },
        stroke: {
          curve: 'straight',
          colors: ['#4c87cf'],
          width: 1
        },
        fill: {
          type: 'solid',
          opacity: 0.2
        },
        dataLabels: {enabled: false},
      }.to_json,
      ':series': [
        {name: t(:members), data: data_points}
      ].to_json,
      height: '50px'
    )
  end

end