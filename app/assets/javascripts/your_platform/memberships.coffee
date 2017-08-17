# $(document).ready ->
#   $('body.memberships .box_memberships .box_header .edit_button').remove()

reload_membership_validity_ranges = ->
  $('table.memberships tr').addClass 'reloading'
  $.get {
    url: "/api/v1/memberships",
    data: {
      object_gid: $('body').data('navable')
    },
    success: (memberships)->
      for membership in memberships
        tr = $("tr.membership_#{membership.id}")
        valid_from_col = $(tr.find('td')[3])
        valid_to_col = $(tr.find('td')[4])

        valid_from_col.find('.best_in_place')
            .data('bip-value', membership.valid_from_localized_date)
            .data('bip-original-content', membership.valid_from_localized_date)
            .text(membership.valid_from_localized_date)

        valid_to_col.find('.best_in_place')
            .data('bip-value', membership.valid_to_localized_date)
            .data('bip-original-content', membership.valid_to_localized_date)
            .text(membership.valid_to_localized_date)

        tr.removeClass 'reloading error'
    error: ->
      $('table.memberships tr').addClass 'error'
  }

$(document).on 'best_in_place:success best_in_place:error', 'body.memberships table.memberships', ->
  reload_membership_validity_ranges()