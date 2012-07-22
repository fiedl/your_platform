module WorkflowKit
  class WorkflowAdditions
    # This class is here, because rails needs the class inside a file named consitently to path and filename.
    # It does nothing but to make sure that the following class can add functionality to 
    # the gem's WorkflowKit::Workflow class rather than overriding the original class.
  end

#  class Workflow
#    ::ActiveRecord::Base.is_structureable   ancestor_class_names: %w(Group)
#
#    def title
#      name
#    end
#
#    def name_as_verb
#      name.gsub( /ung/, 'en' ).downcase
#    end
#
#  end
end
