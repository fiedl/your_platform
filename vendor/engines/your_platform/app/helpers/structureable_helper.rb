module StructureableHelper

  def add_structureable_button( parent_structureable )
    render(partial: 'shared/add_structureable', 
           locals: { parent_id: parent_structureable.id, parent_type: parent_structureable.class.name })
  end

end
