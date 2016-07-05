require 'best_in_place'
require_dependency(Gem::Specification.find_by_name('best_in_place').gem_dir + '/' + 'lib/best_in_place/controller_extensions')

module BestInPlace
  module ControllerExtensions

  private
    # Override for:
    # best_in_place-3.1.0/lib/best_in_place/controller_extensions.rb @ line 9
    #
    # In order to make sure that the new value is returned a result as a controlling
    # mechanism. The original method just sends a `:no_content` header.
    #
    def respond_bip_ok(obj, options = {})
      param_key = options[:param] ||= BestInPlace::Utils.object_to_key(obj)

      updating_attr = params[param_key].keys.first

      if renderer = BestInPlace::DisplayMethods.lookup(obj.class, updating_attr)
        render json: renderer.render_json(obj)
      else
        render json: {
          display_as: obj.send(updating_attr)
          # object: obj.as_json
        }
      end
    end

  end
end
