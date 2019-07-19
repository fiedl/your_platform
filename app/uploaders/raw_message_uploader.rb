class RawMessageUploader < BaseUploader

  # Extend the `store!` method to allow Strings and Mail::Messages to
  # be passed directly.
  #
  # See: https://github.com/carrierwaveuploader/carrierwave/wiki/How-to:-Upload-from-a-string-in-Rails-3-or-later
  #
  def store!(new_file = nil)
    if new_file.kind_of? String
      new_file = RawMessageUploadStringIO.new(filename, new_file)
    elsif new_file.kind_of? Mail::Message
      new_file = RawMessageUploadStringIO.new(filename, new_file.to_s)
    end
    super(new_file)
  end

  def filename
    'message.eml'
  end

end

class RawMessageUploadStringIO < StringIO
  attr_accessor :filepath

  def initialize(*args)
    super(*args[1..-1])
    @filepath = args[0]
  end

  def original_filename
    File.basename(@filepath)
  end
end
