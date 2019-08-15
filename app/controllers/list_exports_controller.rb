class ListExportsController < ApplicationController
  expose :group
  expose :list_preset, -> { params[:list] }
  expose :quarter, -> { params[:quarter] }

  expose :year, -> { params[:year] }
  expose :date, -> { "#{year}-01-01".to_date if year }

  def show
    authorize! :read, group
    authorize! :export_member_list, group

    list_preset_i18n = I18n.translate(list_preset) if list_preset.present?
    file_title = "#{group.name} #{list_preset_i18n} #{date || Time.zone.now}".parameterize

    # Log exports.
    #
    PublicActivity::Activity.create!(
      trackable: group,
      key: "Export #{params[:list] || params[:pdf_type]}",
      owner: current_user,
      parameters: params.to_unsafe_hash.except('authenticity_token')
    )

    respond_to do |format|
      format.csv do

        # The export for "DPAG Internetmarke" requires an "latin western 1" encoding.
        # Everything else, we encode as UTF-8.
        #
        csv_data = Rack::MiniProfiler.step("retrieve csv data") do
          group.export_list(list_preset: list_preset, format: :csv, quarter: quarter, date: date, current_user: current_user)
        end
        if list_preset.try(:include?, 'dpag_internetmarke')
          csv_data = csv_data.encode('ISO-8859-1')
        else
          # See: http://railscasts.com/episodes/362-exporting-csv-and-excel
          #bom = "\377\376".force_encoding('utf-16le')
          bom = "\xEF\xBB\xBF".force_encoding('utf-8') # UTF-8
          csv_data = bom + csv_data
        end

        send_data csv_data, filename: "#{file_title}.csv"
      end
      format.xls do
        xls_data = Rack::MiniProfiler.step("retrieve xls data") do
          group.export_list(list_preset: list_preset, format: :xls, quarter: quarter, date: date, current_user: current_user)
        end
        send_data(xls_data, type: 'application/xls; charset=utf-8; header=present', filename: "#{file_title}.xls")
      end
    end

  end

end