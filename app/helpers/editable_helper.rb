# -*- coding: utf-8 -*-

# Hilfsmodul für editierbare Bereiche, z.B. Profilfelder etc.
module EditableHelper

  # Erzeugt <span class="editable" data-show-url=... data-edit-url=... ></span>.
  # Parameter: css_class, object
  def editable_span_tag( params, &block )
    css_class = params[ :css_class ]
    object = params[ :object ]
    controller = params[ :controller ]
    id = params[ :id ]
    
    urls = {}
    [ 'show', 'edit', 'update', 'create', 'new' ].each do |action| 
      urls[ "data-#{action}-url" ] = url_for controller: controller, action: action, id: id
    end
    
    content_tag( :span, { class: "editable #{css_class}" }.merge( urls ) ) do
      yield
    end
    
  end

end
