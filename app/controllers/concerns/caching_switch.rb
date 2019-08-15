concern :CachingSwitch do
  included do
    around_action :use_caching_ability_switch
  end

  private

  def use_caching_ability_switch
    if can? :use, :caching
      yield
    else
      Rails.cache.uncached { yield }
    end
  end
end