require 'carrierwave/processing/mime_types'

class AttachmentUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  include CarrierWave::MiniMagick

  # Include the Sprockets helpers for Rails 3.1+ asset pipeline compatibility:
  # include Sprockets::Helpers::RailsHelper
  # include Sprockets::Helpers::IsolatedHelper

  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    model.id || raise(RuntimeError, 'Model has no id. But need one to save the file.')
    "#{Rails.root}/uploads/#{Rails.env}_env/#{model.class.base_class.to_s.underscore}s/#{model.id}"
  end
  def cache_dir
    # model.id || raise(RuntimeError, 'Model has no id. But need one to save the file.')
    # "#{Rails.root}/tmp/uploads/#{Rails.env}_env/#{model.class.to_s.underscore}s/#{model.id}"
    Rails.root || raise(RuntimeError, 'no rails root')
    Rails.env || raise(RuntimeError, 'no rails env')
    "#{Rails.root}/tmp/uploads/#{Rails.env}_env/"
  end

  process :set_content_type
  process :store_dimensions

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
  version :thumb, :if => :need_thumb? do
    process :cover
    process :resize_to_limit => [300,300]
    process :convert => :png, if: :pdf?
    process :modify_content_type

    def full_filename(for_file = model.attachment.file)
      "thumb.png"
    end
  end

  version :medium, :if => :need_thumb? do
    process :cover, if: :pdf?
    process :resize_to_limit => [600,600]
    process :convert => :png, if: :pdf?
    process :modify_content_type
  end

  version :big, if: :need_thumb? do
    process :cover, if: :pdf?
    process :resize_to_limit => [1500,1500]
    process :convert => :png, if: :pdf?
    process :modify_content_type
  end

  version :video_thumb, :if => :video? do
    process :create_video_thumb
    process :set_content_type => [ "image/jpeg" ]
    def full_filename( for_file = model.attachment.file )
      "video-thumb.jpg"
    end
  end

  def video?(new_file)
    new_file.content_type.include?('video')
  end

  def svg?(new_file)
    new_file && new_file.content_type.present? && new_file.content_type.include?('svg')
  end

  def raster_image?(new_file)
    image?(new_file) and not svg?(new_file)
  end

  def image?(new_file)
    new_file && new_file.content_type.present? && new_file.content_type.include?('image')
  end

  def pdf?(new_file)
    new_file && new_file.content_type.present? && new_file.content_type.include?('pdf')
  end

  def need_thumb?(new_file)
    raster_image?(new_file) or pdf?(new_file)
  end

  def set_content_type
    model.content_type = self.file.content_type
  end

  # This method filteres out all pages except for the cover page.
  # This is used when making a thumbnail for pdf files. pdf files can have several pages,
  # but only the first page should be used for the thumbnail, not one thumbnail for each page.
  #
  # Taken from: http://afreshcup.com/home/2012/9/27/thumbnailing-pdfs-with-minimagick.html
  #
  def cover
    manipulate! do |img|
      img.format("png", 0)
      img.resize("1500x1500")
      img = yield(img) if block_given?
      img
    end
  end

  def modify_content_type( *args )
    type = args[0] || "image/png"
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

  def store_dimensions
     if file && model
       if image?(file)
         model.width, model.height = ::MiniMagick::Image.open(file.file)[:dimensions]
       elsif video?(file)
         # http://stackoverflow.com/a/11236144/2066546
         json = `ffprobe -v quiet -print_format json -show_format -show_streams "#{self.file.file}"`
         info = JSON.parse(json)
         model.width = info["streams"].first["width"]
         model.height = info["streams"].first["height"]
       end
     end
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

  def url(version = nil)
    model.id || raise(RuntimeError, 'Model has no id.')
    if version
      filename = self.send(version).current_path
    else
      filename = self.current_path
    end
    if filename
      extension = File.extname(filename).gsub(/^./, '')
      basename = File.basename(filename).gsub(/.#{extension}$/, '')
      Rails.application.routes.url_helpers.attachment_download_path(id: model.id, basename: basename, extension: extension, version: version || version_name)
    else
      nil
    end
  end

  def filetitle
    File.basename(to_s)
  end


  def self.valid_versions
    [:thumb, :medium, :big, :video_thumb]
  end

end
