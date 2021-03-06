Mime::Type.register "application/xls", :xls unless Mime::Type.lookup_by_extension(:xls)
#Mime::Type.register 'text/x-vcard', :vcf

# http://stackoverflow.com/a/2443434/2066546
#Mime::Type.register "video/mp4", :m4v
Mime::Type.register "video/mp4", :mp4
Rack::Mime::MIME_TYPES.merge!({
  ".mp4"     => "video/mp4",
  ".m4v"     => "video/mp4",
  ".mp3"     => "audio/mpeg",
  ".m4a"     => "audio/mpeg"
})