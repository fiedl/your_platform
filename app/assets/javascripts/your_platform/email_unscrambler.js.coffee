# This script will remove spam-protective strings that have been
# inserted in: app/helpers/email_helper.rb
#
unscramble = (text)->
  text.replace("-without-spam", "")
    .replace("no-spam-", "")

unscramble_email_tags = (html)->
  # http://stackoverflow.com/a/1770981/2066546
  $(html).find('a[href^="mailto:"]').each ->
    a_tag = $(this)
    a_tag.html unscramble a_tag.html()
    a_tag.attr 'href', unscramble(a_tag.attr('href'))

$(document).ready ->
  unscramble_email_tags $(document)

$(document).on 'process', 'div', ->
  unscramble_email_tags $(document)

$(document).on 'save', '.wysiwyg', ->
  wysiwyg = $(this)
  setTimeout ->
    unscramble_email_tags wysiwyg
  , 800