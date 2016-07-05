module WorkflowKit
  class Parameter < ActiveRecord::Base
    self.table_name = "workflow_kit_parameters"

    attr_accessible :key, :value if defined? attr_accessible

    belongs_to :parameterable, polymorphic: true

    def key
      return super.to_sym unless super.kind_of? Symbol
      return super
    end

    def value
      v = super
      v = v.to_i if ( not v.to_i == nil ) and ( v.to_i.to_s == v ) if v.respond_to?( :to_i )
      v = true if v == "true"
      v = false if v == "false"
      return v
    end

    def to_hash
      return { key => value }
    end

    def self.to_hash( parameters )
      parameter_hashes = parameters.collect do |parameter|
        parameter.to_hash
      end
      merged_hash = parameter_hashes.inject { |all, h| all.merge( h ) }
      return merged_hash
    end

  end
end
