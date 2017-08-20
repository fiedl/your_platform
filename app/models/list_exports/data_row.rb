module ListExports

  # List data is stored in Array. Each array item represents
  # a DataRow. The rows are either ActiveRecord objects or Hashes.
  #
  # This class abstracts this distinction away by defining one single
  # access method: `column`.
  #
  #     data_rows.collect do |data_row|
  #       column_names.collect do |column_name|
  #         data_row.column(column_name)
  #       end
  #     end
  #
  class DataRow

    def initialize(object, options = {})
      @object = object
      @object = @object.becomes ListExports::ListExportUser if @object.kind_of? User and not @object.kind_of? ListExports::ListExportUser
      @object.list_export_group = options[:group] if @object.respond_to? :list_export_group
    end

    def column(column_name)
      if @object.respond_to? :values
        @object[column_name.to_s] || @object[column_name.to_sym]
      elsif @object.respond_to? column_name
        @object.try(:send, column_name)
      else
        raise RuntimeError, "Don't know how to access the given attribute or value: #{column_name}. Object: #{@object.class.name} #{@object.try(:id)}."
      end
    end

    # This is a workaround for the to_xls gem, which requires to access the attributes
    # by method in order to write the columns in the correct order.
    #
    def method_missing(method_name, *args, &block)
      self.column(method_name)
    end

  end
end
