class String
  
  alias old_to_datetime to_datetime
  
  def to_datetime
    
    if (self[4..8] == "00000") || (self.length == 4)  # 20030000 || 2003
      str = self[0..3] + "-01-01" # 2003-01-01
      return str.to_datetime

    elsif (self[6..8] == "000")  # 20011000000000Z (no day, but month)
      str = "#{self[0..3]}-#{self[4..5]}-01"  # 2001-10-01
      return str.to_datetime

    else
      old_to_datetime.in_time_zone

    end
  end
  
end