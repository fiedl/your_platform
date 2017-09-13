require 'best_in_place'
require_dependency(Gem::Specification.find_by_name('best_in_place').gem_dir + '/' + 'lib/best_in_place/helper')

module BestInPlace
  module Helper

  private

    # This overrides the lookup for best in place displays.
    # The original method is defined here:
    #   https://github.com/bernat/best_in_place/blob/master/lib/best_in_place/helper.rb#L93
    #
    # This is needed in order to render according to the definitions of
    #   config/initializers/best_in_place_display_definitions.rb
    #
    def best_in_place_build_value_for(object, field, opts)
      return "" if object.send(field).blank?

      renderer = BestInPlace::DisplayMethods.lookup(object.class, field) || BestInPlace::DisplayMethods.lookup(object.class.base_class, field)

      if renderer.nil?
        return object.send(field).to_s
      elsif renderer.opts[:type] == :helper
        BestInPlace::ViewHelpers.send(renderer.opts[:method], object.send(field))
      elsif renderer.opts[:type] == :model
        object.send(renderer.opts[:method]).to_s
      elsif renderer.opts[:type] == :proc
        renderer.opts[:proc].call(object.send(field))
      end

    end

  end
end