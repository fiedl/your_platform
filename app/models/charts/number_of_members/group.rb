class Charts::NumberOfMembers::Group
  include ActiveModel::Conversion

  def initialize(group:, name: nil)
    @group = group
    @name = name
  end

  def group
    @group
  end

  def name
    @name || group.name
  end

  def years
    (2014..(Time.zone.now.year)).to_a
  end

  def data_points
    years.collect do |year|
      group.memberships.at_time(Time.zone.now.end_of_year.change(year: year)).count
    end
  end

  def current_members_count
    group.memberships.count
  end

  def current_members_change
    group.memberships.count - group.memberships.at_time(1.year.ago).count
  end

  def term_report
    nil
  end

  def sub_charts
    [
      self
    ]
  end

  def as_json(*options)
    {
      name: name,
      group: group,
      years: years,
      data_points: data_points,
      count: current_members_count,
      change: current_members_change,
      change_title: "Veränderung der letzten zwölf Monate"
    }
  end

end