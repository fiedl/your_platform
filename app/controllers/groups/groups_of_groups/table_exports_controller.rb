class Groups::GroupsOfGroups::TableExportsController < ApplicationController

  expose :group, -> { Group.find params[:groups_of_group_id] }

  # GET /groups_of_groups/123/exports/excel.xls
  #
  def show
    authorize! :read, group

    file_title = "#{group.name} #{Time.zone.now}".parameterize

    respond_to do |format|
      format.csv do
        send_data csv_data, filename: "#{file_title}.csv"
      end
      format.xls do
        send_data xls_data, type: 'application/xls; charset=utf-8; header=present', filename: "#{file_title}.xls"
      end
    end
  end


  private

  def html_data
    render_partial(group.to_partial_path, group: group)
  end

  def list_export
    ListExports::HtmlTable.new(html_data)
  end

  def csv_data
    list_export.to_csv
  end

  def xls_data
    list_export.to_xls
  end

end