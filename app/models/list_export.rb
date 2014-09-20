
# This extends the your_platform model.
require_dependency YourPlatform::Engine.root.join( 'app/models/list_export' ).to_s

class ListExport

  alias_method :original_columns, :columns
  def columns
    # Im Wingolf soll für alle Benutzer der BV angezeigt werden, dem der Benutzer
    # zugeordnet ist. Für Aktive ist dieser Eintrag leer.
    #
    if @data.respond_to?(:first) && @data.first.kind_of?(User)
      original_columns + [:cached_bv_name]
    else
      original_columns
    end
  end

end

class ListExportUser
  def cached_bv_name
    cached(:bv).try(:name)
  end
end