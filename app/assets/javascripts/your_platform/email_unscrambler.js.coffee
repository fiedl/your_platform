# This script will remove spam-protective strings that have been
# inserted in: app/helpers/email_helper.rb
#
unscramble = (text)->
  text.replace("-without-spam@no-spam-", "@")

$(document).ready ->
  # http://stackoverflow.com/a/1770981/2066546
  $('a[href^="mailto:"]').each ->
    a_tag = $(this)
    a_tag.html unscramble a_tag.html()
    a_tag.attr 'href', unscramble(a_tag.attr('href'))