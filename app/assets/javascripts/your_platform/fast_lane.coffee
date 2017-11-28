$(document).ready ->

  App.current_url_without_fast_lane = ->
    separator = "?"
    separator = "&" if window.location.href.indexOf("?") > -1
    window.location + separator + "no_fast_lane=true"

  if $('body').hasClass('fast-lane')
    $.get '/api/v1/current_role', {object_gid: $('body').data('navable')}, (current_role)->
      if current_role['officer?']
        $('#flash_area').prepend("
          <div class='alert alert-info fast_lane'>
            #{I18n.t('you_can_edit_this_page')}
            <a href='#{App.current_url_without_fast_lane()}' id='load_editable_page_version'>
              #{I18n.t('load_editable_version')}.
            </a>
            <a href='/renew_cache?gid=#{$('body').data('navable')}' id='renew_cache'>
              #{I18n.t('renew_cache')}.
            </a>
          </div>
        ")

  else if window.location.href.indexOf('no_fast_lane') > -1
    history.pushState(null, null, window.location.href.replace('?no_fast_lane=true', '').replace('&no_fast_lane=true', ''))


