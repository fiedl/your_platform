module EditModeHelper
  # Returns a span tag which contains a group of editable elements
  # which should only be shown in edit mode.
  # 
  #   edit_mode_group_span do
  #     # tool buttons: edit, save, cancel
  #     # ...
  #   end
  # 
  # will basically return
  # 
  #   <span class="edit_mode_group">
  #     ...
  #   </span>
  # 
  # The rest is done via javascript.
  def edit_mode_group_span( &block )
    content_tag :span, :class => 'edit_mode_group' do
      yield 
    end
  end


  # Returns a span tag which is only shown in edit mode.
  # 
  #   show_only_in_edit_mode_span do
  #     content_tag :p do
  #       "This text is shown only in edit mode."
  #     end
  #   end
  # 
  # will basically return
  # 
  #   <span class="show_only_in_edit_mode">
  #     <p>
  #       This text is shown only in edit mode.
  #     </p>
  #   </span>
  # 
  # The rest is done via javascript.
  def show_only_in_edit_mode_span( &block )
    content_tag :span, :class => 'show_only_in_edit_mode' do
      yield 
    end
  end

  # Returns a span tag which is only shown when *not* in edit mode.
  # 
  #   do_not_show_in_edit_mode_span do
  #     content_tag :p do
  #       "This text is not shown in edit mode."
  #     end
  #   end
  # 
  # will basically return
  # 
  #   <span class="do_not_show_in_edit_mode">
  #     <p>
  #       This text is not shown in edit mode.
  #     </p>
  #   </span>
  # 
  # The rest is done via javascript.
  def do_not_show_in_edit_mode_span( &block )
    content_tag :span, :class => 'do_not_show_in_edit_mode' do
      yield
    end
  end
end