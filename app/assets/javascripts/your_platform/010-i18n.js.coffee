# This initializes the i18n-js gem.
# https://github.com/fnando/i18n-js
#
# From javascript, one can use I18n just like in rails:
# 
#     I18n.translate 'foo'
#     I18n.t 'foo
#     I18n.t 'sent_to_recipients', {number: 10}
#
$(document).ready ->
  I18n.locale = $('body').data('locale') || "de"