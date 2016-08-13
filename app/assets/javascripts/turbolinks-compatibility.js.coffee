# This makes turbolinks 5 events compatible to older versions. Therefore,
# jquery.turbolinks does still work.
#
# Source: https://github.com/turbolinks/turbolinks/blob/master/src/turbolinks/compatibility.coffee
# See also: https://www.gorails.com/episodes/upgrade-to-turbolinks-5
#
# Internal: https://trello.com/c/A9xa7mM6/971-turbolinks-5

{defer, dispatch} = Turbolinks

handleEvent = (eventName, handler) ->
  document.addEventListener(eventName, handler, false)

translateEvent = ({from, to}) ->
  handler = (event) ->
    event = dispatch(to, target: event.target, cancelable: event.cancelable, data: event.data)
    event.preventDefault() if event.defaultPrevented
  handleEvent(from, handler)

translateEvent from: "turbolinks:click", to: "page:before-change"
translateEvent from: "turbolinks:request-start", to: "page:fetch"
translateEvent from: "turbolinks:request-end", to: "page:receive"
translateEvent from: "turbolinks:before-cache", to: "page:before-unload"
translateEvent from: "turbolinks:render", to: "page:update"
translateEvent from: "turbolinks:load", to: "page:change"
translateEvent from: "turbolinks:load", to: "page:update"

loaded = false
handleEvent "DOMContentLoaded", ->
  defer ->
    loaded = true
handleEvent "turbolinks:load", ->
  if loaded
    dispatch("page:load")

jQuery?(document).on "ajaxSuccess", (event, xhr, settings) ->
  if jQuery.trim(xhr.responseText).length > 0
    dispatch("page:update")