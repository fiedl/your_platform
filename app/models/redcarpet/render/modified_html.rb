class Redcarpet::Render::ModifiedHtml < Redcarpet::Render::HTML

  def initialize(options={})
    @unrendered_content = options[:unrendered_content]
    super options
  end

  # def list_item(text, list_type)
  #   binding.pry
  #
  # end

end