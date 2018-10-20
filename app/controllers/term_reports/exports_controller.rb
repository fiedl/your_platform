class TermReports::ExportsController < TermReportsController

  def show
    authorize! :index, TermReport

    file_title = "#{term.title} #{Time.zone.now}".parameterize

    respond_to do |format|
      format.csv do
        send_data csv_data, filename: "#{file_title}.csv"
      end
      format.xls do
        send_data xls_data, type: 'application/xls; charset=utf-8; header=present', filename: "#{file_title}.xls"
      end
    end
  end

  def html_data
    render_to_string "/term_reports/index", term_id: term.id, formats: [:html]
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