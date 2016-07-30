class BaseUploader < CarrierWave::Uploader::Base
  storage :file

  def store_dir
    model.id || raise('Model has no id. But need one to save the file.')
    "#{Rails.root}/uploads/#{Rails.env}_env/#{model.class.base_class.to_s.underscore}s/#{model.id}"
  end
  def cache_dir
    Rails.root || raise('no rails root')
    Rails.env || raise('no rails env')
    "#{Rails.root}/tmp/uploads/#{Rails.env}_env/"
  end
end