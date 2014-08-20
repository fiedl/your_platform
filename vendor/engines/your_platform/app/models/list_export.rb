# This class helps to export data to CSV, XLS and possibly others.
#
# Example:
#
#     class PeopleController
#       def index
#         # ...
#         format.xls do
#           send_data ListExport.new(@people, :birthday_list).to_xls
#         end
#       end
#     end
#
# The following ressources might be helpful.
#
#   * https://github.com/splendeo/to_xls
#   * https://github.com/zdavatz/spreadsheet
#   * Formatting xls: http://scm.ywesee.com/?p=spreadsheet/.git;a=blob;f=lib/spreadsheet/format.rb
#   * to_xls gem example: http://stackoverflow.com/questions/15600987/rails-export-arbitrary-array-to-excel-using-to-xls-gem
# 
class ListExport
  attr_accessor :data, :preset, :csv_options
  
  def initialize(data, preset = nil)
    @data = data; @preset = preset
    @csv_options =  { col_sep: ';', quote_char: '"' }
    data = sorted_data
  end
  
  def columns
    case preset.to_s
    when 'birthday_list'
      [:last_name, :first_name, :cached_name_suffix, :cached_localized_birthday_this_year, :cached_localized_date_of_birth, :cached_current_age]
    when 'address_list' then []
    when 'phone_list' then []
    when 'email_list' then []
    when 'member_development' then []
    else
      # This name_list is the default.
      [:last_name, :first_name, :cached_name_suffix, :personal_title, :academic_degree]
    end
  end
  
  def headers
    columns.collect do |column| 
      I18n.translate column.to_s.gsub('cached_', '').gsub('localized_', '')
    end
  end
  
  def sorted_data
    case preset
    when 'birthday_list'
      data.sort_by do |user|
        user.cached_date_of_birth.try(:strftime, "%m-%d") || ''
      end
    else
      data
    end
  end
  
  def to_csv
    CSV.generate(csv_options) do |csv|
      csv << headers
      data.each do |row|
        csv << columns.collect { |column_name| row.try(:send, column_name) }
      end
    end
  end
  
  def to_xls
    data.to_xls(columns: columns, headers: headers, header_format: {weight: 'bold'})
  end
  
  def to_s
    to_csv
  end
end

require 'user'
class User
  def cached_current_age
    cached_age
  end
  def cached_localized_birthday_this_year
    I18n.localize cached_birthday_this_year
  end
  def cached_localized_date_of_birth
    I18n.localize cached_date_of_birth
  end
end