# -*- coding: utf-8 -*-

# Hilfsmodul für editierbare Bereiche, z.B. Profilfelder etc.
module EditableHelper

  # Erzeugt <span class="editable" showUrl=... editUrl=... ></span>.
  # Parameter: controller, id
  def editable_span_tag( params )

    urls = {}
    [ 'show', 'edit', 'update', 'create', 'new' ].each do |action| 
      urls[ "#{action}_url" ] = url_for( params.merge( action: action ) )
    end
    
    content_tag( :span, "", { class: "editable" }.merge( urls ) )
    
  end

end
