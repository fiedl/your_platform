module ArchivableHelper

  # This inserts the 'archive' and 'unarchive' buttons for archivable
  # objects. The PUT request is sent via ajax by the archivable.js.coffe
  # script.
  #
  def archive_button(archivable, label = "")
    if not archivable.archived?
      link_to icon(:trash) + label, archivable, class: 'btn btn-info archive_button', title: t(:archive_str, str: archivable.title)
    elsif archivable.archived?
      link_to icon(:undo) + label, archivable, class: 'btn btn-info unarchive_button', title: t(:restore)
    end
  end

  def archived_label(archivable)
    if archivable.archived?
      content_tag(:span, t(:archived), class: 'label label-info archived_label')
    end
  end

end