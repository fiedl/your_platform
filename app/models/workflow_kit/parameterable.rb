
module WorkflowKit

  module Parameterable
    def has_many_parameters
      
      has_many :parameters, as: :parameterable, dependent: :destroy, autosave: true

      include ParameterableInstanceMethods

    end
  end

  module ParameterableInstanceMethods

    # returns the associated parameters as hash
    def parameters_to_hash
      WorkflowKit::Parameter.to_hash( parameters )
    end

    def parameter_hash
      parameters_to_hash
    end

    def parameters=( new_parameter_hash )
            
      return super( new_parameter_hash ) if not new_parameter_hash.kind_of? Hash # original method
      
      parameters.destroy_all # delete previous parameters
      if new_parameter_hash
        new_parameter_hash.each do |key, value|
          self.parameters.build( key: key, value: value )
        end
      end

    end

  end

end
