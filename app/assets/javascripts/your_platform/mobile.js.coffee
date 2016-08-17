# This acts as a helper for our mobile apps.
# See: https://github.com/fiedl/Vademecum

$(document).ready ->
  load_from_partial 'body.mobile.dashboard .events_list_partial', 'events'

load_from_partial = (selector, partial)->
  target = $(selector)
  url = "/mobile/partials/#{partial}"
  $.ajax {
    type: 'GET',
    url: url,
    success: (result)->
      $(selector).replaceWith result
      $(selector).hide()
      $(selector).fadeIn()
      $(selector).process()
      bind_links_to_vcf_files_within selector
    failure: (result)->
      target.fadeOut()
      console.log "failed to load mobile partial #{url}"
      console.log result
  }
