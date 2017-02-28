# This breadcrumb behaviour has been extracted from:
# https://github.com/fiedl/slim_breadcrumb

# Define some timers: The slim elements are not to be shown immediately after
# mouseover(), but a while after, that is if the user stays over the element.
breadcrumb_slim_in_timer = 0
breadcrumb_slim_out_timer = 0

# status variable that knows whether an animation is currently running.
animating = false

# Time required to dwell.
time_to_dwell = 1000 # milliseconds


# show animation
#
breadcrumb_slim_effect = "drop"
show_slim_breadcrumbs = ->
  elements_to_show = $('ul.breadcrumbs li.slim a')
  for elem in elements_to_show
    unless $(elem).is(":visible")
      animating = true
      $(elem).show(breadcrumb_slim_effect, ->
        animating = false
      )


# hide animation
#
hide_slim_breadcrumbs = ->
  if $("ul.breadcrumbs li.slim a:visible").html()
    animating = true
    $('ul.breadcrumbs li.slim a:visible').hide('fade', 'fast', ->
      animating = false
    )


# Show all elements on dblclick.
#
$(document).on 'dblclick', 'ul.breadcrumbs', ->
  delay_time = 0
  delay_time = 600 if animating # because then, a click event is performing an animation
  animating = true
  $("ul.breadcrumbs li.slim a:not(:visible)").delay(delay_time).show("drop", ->
    animating = false
  )


# Show the slim element on click as well.
#
$(document).on 'click', 'ul.breadcrumbs li.slim', ->
  if not animating
    show_slim_breadcrumbs($(this))


# If the mouse leaves the breadcrumb, hide the slim elements.
#
breadcrumb_slim_out_timer = null
$(document).on 'mouseout', 'ul.breadcrumbs', ->
  breadcrumb_slim_out_timer = setTimeout(->
    hide_slim_breadcrumbs()
  , time_to_dwell)
$(document).on 'mouseover', 'ul.breadcrumbs', ->
  clearTimeout(breadcrumb_slim_out_timer)


# Show the slim elements if the mouse stays over the separator.
#
breadcrumb_slim_in_timer = null
$(document).on 'mouseover', 'ul.breadcrumbs li.slim', ->
  breadcrumb_slim_in_timer = setTimeout(->
    show_slim_breadcrumbs()
  , time_to_dwell)
$(document).on 'mouseout', 'ul.breadcrumbs li.slim', ->
  clearTimeout(breadcrumb_slim_in_timer)


$(document).ready ->

  # The last element of the whole bread crumb path is not to be shown slim
  # in order to not have an open end (like " A >> C > D > " if E is slim).
  $("ul.breadcrumbs li").last().removeClass("slim")

  # Initially hide all slim elements.
  $("ul.breadcrumbs li.slim a").hide()

  # The first breadcrumb should not use turbolinks as it may refer to an
  # external site. This would cause a silent redirect error.
  $('ul.breadcrumbs li:first a').data('no-turbolink', true)

