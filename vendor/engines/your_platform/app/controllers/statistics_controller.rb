class StatisticsController < ApplicationController
  
  skip_authorization_check only: [:index, :show]
  
  def index
    authorize! :index, :statistics
    
    @list_presets = [
      'corporation_joining_statistics', 'aktivitates_join_and_persist_statistics'
    ]
  end
  
  def show
    authorize! :read, :statistics
    
    @list_preset = params[:list] || raise('no list preset given. use parameter "list".')
    
    case @list_preset
    when 'corporation_joining_statistics'
      @list_export = ListExport.new(Group.corporations_parent, 'join_statistics')
    when 'aktivitates_join_and_persist_statistics'
      @list_export = ListExport.new(Group.alle_aktiven, 'join_and_persist_statistics')
    else
      raise "statistics preset unknown: #{@list_preset}."
    end

    respond_to do |format|
      format.html  # render view
      format.csv do
        authorize! :export, :statistics
        
        bom = "\xEF\xBB\xBF".force_encoding('utf-8') # UTF-8
        send_data (bom + @list_export.to_csv), filename: ("#{t @list_preset} #{Time.zone.now}".parameterize + ".csv")
      end
    end
  end
  
end