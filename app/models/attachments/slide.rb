class Attachments::Slide < Attachments::Image
  include RailsSettings::Extend

  def title
    read_attribute(:title) || parent.try(:title)
  end

  def subtitle
    description
  end

  def image_path
    file_path
  end

  def read_more_button_path
    polymorphic_path(parent)
  end

  def read_more_button_text
    I18n.t(:read_more)
  end

  def self.model_name
    Attachment.model_name
  end

end