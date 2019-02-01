FactoryGirl.define do
  factory :attachment do |f|
    f.title 'New Attachment'
    f.description 'Descriptive description of the new attachment.'
    f.file { Rack::Test::UploadedFile.new(File.expand_path(File.join(__FILE__, '../../support/uploads/pdf-upload.pdf')), "application/pdf") }

    factory :image_attachment do |f|
      f.file { Rack::Test::UploadedFile.new(File.expand_path(File.join(__FILE__, '../../support/uploads/image-upload.png'))) }
    end

  end
end