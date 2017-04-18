class Groups::GroupsOfGroups::TableExportsController < ApplicationController

  expose :group, -> { Group.find params[:groups_of_group_id] }

  # GET /groups_of_groups/123/exports/excel.xls
  #
  def show
    authorize! :read, group

    file_title = "#{group.name} #{Time.zone.now}".parameterize

    respond_to do |format|
      format.csv do
        byte_order_mark = "\xEF\xBB\xBF".force_encoding('utf-8') # UTF-8
        send_data byte_order_mark + csv_data, filename: "#{file_title}.csv"
      end
      format.xls do
        send_data(xls_data, type: 'application/xls; charset=utf-8; header=present', filename: "#{file_title}.xls")
      end
    end
  end


  private

  def html_data
    @html_data ||= render_partial(group.to_partial_path, group: group)
  end

  def table_rows
    rows = []
    doc = Nokogiri::HTML(html_data)
    doc.xpath('//table/*/tr').each do |row|
      tarray = []
      row.xpath('th', 'td').each do |cell|
        tarray << cell.text
      end
      rows << tarray
    end
    rows
  end

  def csv_data
    doc = Nokogiri::HTML(html_data)
    CSV.generate do |csv|
      table_rows.each do |row|
        csv << row
      end
    end
  end

  def xls_data
    Excelinator.csv_to_xls(csv_data)
  end

end