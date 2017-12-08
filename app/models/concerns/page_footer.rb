module PageFooter

  def show_in_footer
    has_flag? :footer
  end

  def show_in_footer?
    show_in_footer
  end

  def show_in_footer=(new_setting)
    if new_setting
      add_flag :footer
    else
      remove_flag :footer
    end
  end

end