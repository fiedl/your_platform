# This class helps to export data to CSV, XLS and possibly others.
#
# Example:
#
#     class PeopleController
#       def index
#         # ...
#         format.xls do
#           send_data ListExports::BirthdayList.from_people(@people).to_xls
#         end
#       end
#     end
#
# The following ressources might be helpful.
#
#   * https://github.com/splendeo/to_xls
#   * https://github.com/zdavatz/spreadsheet
#   * Formatting xls: http://scm.ywesee.com/?p=spreadsheet/.git;a=blob;f=lib/spreadsheet/format.rb
#   * to_xls gem example: http://stackoverflow.com/questions/15600987/
# 
module ListExports
  class Base
    
    # The data that is to be exported is supposed to be some kind of Array.
    # The array can contain ActiveRecord objects or Hashes.
    #
    # The data array is filled, either in the initializer, or in a `from_xyz` method.
    #
    attr_accessor :data
    
    # This is a way to store export options when initializing.
    #
    attr_accessor :options
    
    def initialize(data, options = {})
      @data = data
      @options = options
    end
    
    # Initialize from group, i.e. the group members are considered to be the
    # export data.
    #
    def self.from_group(group, options = {})
      self.new(group.members.to_a, options.merge({group: group}))
    end
    
    def group
      @options[:group]
    end
    
    # The columns that are to be exported are listed here as array of Symbols or Strings.
    # During the export, these names are used either as methods on the ActiveRecord objects,
    # or as keys for the Hashes in the `data`.
    #
    def columns
      []
    end
    
    # The headers of the tables are, by default, derived from the columns
    # that are to be exported.
    #
    def headers
      columns.collect do |column|
        if column.kind_of? Symbol
          I18n.translate column.to_s.gsub('cached_', '').gsub('localized_', '')
        else
          column
        end
      end
    end
    
    # Wrapping the `data` Array as array of `DataRow` objects
    # unifies the access method: The columns can be accessed using the
    # `column(key)` method.
    #
    def data_rows
      data.collect do |object|
        DataRow.new(object)
      end
    end
    
    # This exports the `data` into a csv formatted String.
    #
    def to_csv
      CSV.generate(csv_options) do |csv|
        csv << headers
        data_rows.each do |row|
          csv << columns.collect do |column_name|
            row.column(column_name)
          end
        end
      end
    end
    
    def csv_options
      {col_sep: ';', quote_char: '"'}
    end
    
    # This exports the `data` into xls format, which can be served via
    # 
    #   send_data(@list_export.to_xls, type: 'application/xls; charset=utf-8; header=present', 
    #     filename: "#{@file_title}.xls")
    #
    # Internally, we use the to_xls gem:
    # https://github.com/splendeo/to_xls
    #
    def to_xls
      data_rows.to_xls(columns: columns, headers: headers, header_format: {weight: 'bold'})
    end
    
  end
end