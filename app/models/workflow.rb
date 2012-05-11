class Workflow < ActiveRecord::Base
  attr_accessible    :name

  is_structureable   ancestor_class_names: %w(Group)

  def title
    name
  end

  def name_as_verb
    name.gsub( /ung/, 'en' ).downcase
  end

end
