FactoryGirl.define do
  factory :attachment do |f|
    f.title 'New Attachment'
    f.description 'Descriptive description of the new attachment.'
    f.file { Rack::Test::UploadedFile.new(File.expand_path(File.join(__FILE__, '../../support/uploads/pdf-upload.pdf'))) }
    after(:create) { |attachment| attachment.update content_type: "application/pdf" }

    factory :image_attachment do |f|
      f.file { Rack::Test::UploadedFile.new(File.expand_path(File.join(__FILE__, '../../support/uploads/image-upload.png'))) }
      after(:create) { |attachment| attachment.update content_type: "image/png" }
    end

  end
end