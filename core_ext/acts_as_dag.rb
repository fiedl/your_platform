# These patches modify the acts-as-dag gem: https://github.com/resgraph/acts-as-dag
# They are applied from config/initializers/acts_as_dag_overrides.rb.
#
module ActsAsDagOverrides
  module CreateCorrectnessValidatorOverrides

    # def validate(record)
    # end

  end
end

Dag::CreateCorrectnessValidator.send(:prepend, ActsAsDagOverrides::CreateCorrectnessValidatorOverrides)