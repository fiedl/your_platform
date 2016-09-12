module FormsHelper

  def array_select_tag(model, attribute, array, options = {})
    collection_select model, attribute, array.collect { |item| [item, item] }, :first, :last, options
  end

end