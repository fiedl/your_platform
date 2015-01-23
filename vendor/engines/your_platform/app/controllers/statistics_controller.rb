class StatisticsController < ApplicationController
  
  skip_authorization_check only: [:index]
  
  def index
    authorize! :index, :statistics
    
    @corporation_joining_statistics_export = ListExport.new(Group.corporations_parent, 'join_statistics')
    
    respond_to do |format|
      format.html  # render view
      format.csv do
        bom = "\xEF\xBB\xBF".force_encoding('utf-8') # UTF-8
        send_data (bom + @corporation_joining_statistics_export.to_csv), filename: ("statistics #{Time.zone.now}".parameterize + ".csv")
      end
    end
  end
  
end