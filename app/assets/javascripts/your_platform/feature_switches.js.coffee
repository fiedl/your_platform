# This ui script helps to make deactivated features (feature switches)
# more intuitive.
#
# Keep in mind that javascript can be turned off. Make sure the feature
# switches are respected at the controller level.

$(document).ready ->
  $('.contact_form .this_feature_has_been_deactivated').each ->
    $(this).closest('.contact_form')
      .find('form, input, submit, textarea, label')
      .attr("disabled", true)
      .css('opacity', '0.7')