require_dependency ActsAsTaggableOn::Engine.root.join('lib/acts_as_taggable_on/tag').to_s

class ActsAsTaggableOn::Tag
  has_many :attachments, as: :parent, dependent: :destroy

  include HasPermalinks

  def title
    if super.present?
      super
    else
      name.humanize
    end
  end

  def image
    attachments.by_type('image').last
  end

  def to_param
    "#{id} #{title}".parameterize
  end

end