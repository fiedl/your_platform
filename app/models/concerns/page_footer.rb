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

  def footer_embedded
    has_flag? :footer_embedded
  end

  def footer_embedded?
    footer_embedded
  end

  def footer_embedded=(new_setting)
    if new_setting
      add_flag :footer_embedded
    else
      remove_flag :footer_embedded
    end
  end

end