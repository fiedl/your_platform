ready = ->
  
  datepickerOptions = 
    changeYear: true,
    showWeek: true
    
  datepickerLocale =
    $("body").data("locale") || "en"
    
  datepickerOptionsForLocale =
    $.datepicker.regional[ datepickerLocale ]
  
  $.datepicker.setDefaults(datepickerOptions, datepickerOptionsForLocale  )

$(document).ready(ready)
$(document).on('page:load', ready)
