# Raise processing errors and do not ignore them silently.
# http://benw.me/posts/carrierwave-failing-silently/
# https://trello.com/c/uL8hQQhL/1399-pdf-uploads-funktionieren-nicht
#
CarrierWave.configure do |config|
  config.ignore_integrity_errors = false
  config.ignore_processing_errors = false
  config.ignore_download_errors = false
end
