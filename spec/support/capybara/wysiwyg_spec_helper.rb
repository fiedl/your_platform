module WysiwygSpecHelper
  def edit_wysiwyg(selector, text)
    text.gsub!("\n", "\\n")
    page.execute_script "$('#{selector}').data('editor').setValue('#{text}');"
  end
end