require 'best_in_place'
require_dependency(Gem::Specification.find_by_name('best_in_place').gem_dir + '/' + 'lib/best_in_place/controller_extensions')

module BestInPlace
  module ControllerExtensions

  private
    # def respond_bip_ok(obj)
    #   #if obj.respond_to?(:id)
    #   #  klass = "#{obj.class}_#{obj.id}"
    #   #else
    #   #  klass = obj.class.to_s
    #   #end
    #   param_key = BestInPlace::Utils.object_to_key(obj)
    #   updating_attr = params[param_key].keys.first
    # 
    #   if renderer = BestInPlace::DisplayMethods.lookup(obj.class.name, updating_attr) || BestInPlace::DisplayMethods.lookup(obj.class.base_class.name, updating_attr)
    #     render :json => renderer.render_json(obj)
    #   else
    #     head :no_content
    #   end
    # end

  end
end
