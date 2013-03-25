# encoding: utf-8
class AttachmentUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  include CarrierWave::RMagick
  # include CarrierWave::MiniMagick

  # Include the Sprockets helpers for Rails 3.1+ asset pipeline compatibility:
  # include Sprockets::Helpers::RailsHelper
  # include Sprockets::Helpers::IsolatedHelper

  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  version :thumb, :if => :image_or_pdf? do
    process :resize_to_limit => [ 100, 100 ]
    process :cover
    process :convert => :png
    process :set_content_type
    def full_filename( for_file = model.attachment.file )
      "thumb.png"
    end
  end

  version :video_thumb, :if => :video? do
    process :create_video_thumb
    process :set_content_type => [ "image/jpeg" ]
  end

  def image_or_pdf?( new_file )
    new_file.content_type.include? 'image' or 
      new_file.content_type.include? 'pdf'
  end

  def video?( new_file )
    new_file.content_type.include? 'video' 
  end
  
  def cover 
    manipulate! do |frame, index|
      frame if index.zero?
    end
  end

  def set_content_type( *args )
    type = args[0]
    type = "image/png" unless type
    self.file.instance_variable_set( :@content_type, type )
  end

  def create_video_thumb( *args )
    original_file = self.file.instance_variable_get( :@file )
    original_file_title = original_file.split( "/" ).last
    thumb_title = "thumb.jpg"
    tmp_thumb_file = original_file.gsub( original_file_title, thumb_title )

    `ffmpeg  -itsoffset -4  -i '#{original_file}' -vcodec mjpeg -vframes 1 -an -f rawvideo -s 200x112 '#{tmp_thumb_file}'`
    `mv '#{tmp_thumb_file}' '#{original_file}'`
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  # def extension_white_list
  #   %w(jpg jpeg gif png)
  # end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "original.#{model.attachment.file.extension}" if original_filename
  # end

end
