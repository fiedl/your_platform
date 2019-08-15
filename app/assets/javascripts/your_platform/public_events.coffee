# This handles special features of the public events box of public websites.

App.process_public_events = (element)->
  $(element).find('ul.website-events li').each ->
    li = $(this)
    if li.find('.best_in_place').count() > 0
      li.append("
        <a class='remove_event_from_public_website show_only_in_edit_mode btn btn-info' title='#{I18n.t('remove_event_from_public_website')}'>
          <span class='fa fa-trash'></span>
        </a>
      ")
      li.process()
      button = li.find('.remove_event_from_public_website')

$(document).ready ->
  App.process_public_events($('body'))

$(document).on 'click', '.remove_event_from_public_website', ->
  li = $(this).closest('li')
  url = li.find('.event.name a').attr('href')
  $(this).closest('.box').trigger('save')
  $(this).closest('ul').find('li').hide()
  $(this).closest('ul').append("<li class='upcoming_event'>...</li>")
  $.ajax {
    url: "#{url}.json",
    method: 'put',
    data: {
      event: {
        publish_on_global_website: false
      }
    }
    success: ->
      box_selector = "#" + li.closest('.box').attr('id')
      $(document).ajax_reload {
        url: App.current_url_without_fast_lane(),
        selector: box_selector,
        success: ->
          $(box_selector).trigger('edit')
      }
  }
  false
