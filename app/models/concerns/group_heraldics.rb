concern :GroupHeraldics do

  included do
    include GroupHeraldicsWappen
    include GroupHeraldicsZirkel
  end

end

concern :GroupHeraldicsWappen do
  included do
    has_many :wappen_attachments, -> { where(title: 'wappen') }, class_name: "Attachment", as: :parent
  end

  def wappen_attachment_path
    wappen_attachments.last.try(:medium_path)
  end

  def wappen_attachment=(file)
    wappen_attachments.create file: file
    self.touch
  end

  def wappen_path
    wappen_attachment_path
  end

  def wappen_url
    wappen_path
  end

  def wappen
    self.wappen_attachments.last
  end

  def wappen=(file)
    self.wappen_attachment = file
  end
end

concern :GroupHeraldicsZirkel do
  included do
    has_many :zirkel_attachments, -> { where(title: 'zirkel') }, class_name: "Attachment", as: :parent
  end

  def zirkel_attachment_path
    zirkel_attachments.last.try(:medium_path)
  end

  def zirkel_attachment=(file)
    zirkel_attachments.create file: file
    self.touch
  end

  def zirkel_path
    zirkel_attachment_path
  end

  def zirkel_url
    zirkel_path
  end

  def zirkel
    self.zirkel_attachments.last
  end

  def zirkel=(file)
    self.zirkel_attachment = file
  end
end