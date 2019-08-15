module CacheHelper

  def renew_cache_button(object)
    link = user_renew_cache_path(object) if object.kind_of? User
    link = group_renew_cache_path(object) if object.kind_of? Group
    link = page_renew_cache_path(object) if object.kind_of? Page
    link = event_renew_cache_path(object) if object.kind_of? Event
    link_to link, method: 'post', title: t(:renew_cache), class: 'btn btn-outline-secondary' do
      fa_icon(:refresh)
    end
  end

end