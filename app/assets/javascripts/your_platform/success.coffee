App.success = (element)->
  element.removeClass 'saving failure error'
  element.addClass 'success', 300
  setTimeout (-> element.removeClass('success', 300)), 5000
