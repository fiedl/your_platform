require 'spec_helper'
require 'carrierwave/test/matchers'

describe AttachmentUploader do
  include CarrierWave::Test::Matchers
  let(:support_dir) { File.expand_path(File.join(__FILE__, "../../support")) }
  
  before do
    @attachment = Attachment.create
    AttachmentUploader.enable_processing = true
    @uploader = AttachmentUploader.new(@attachment, :file)
  end
  after do
    AttachmentUploader.enable_processing = false
  end
  
  describe "PDF upload" do
    before do
      pdf_fixture_path = "#{support_dir}/uploads/pdf-upload.pdf"
      @uploader.store!(File.open(pdf_fixture_path))
    end
    after do
      @uploader.remove!
    end
    subject { @uploader }
    it "should store the file" do
      @uploader.identifier.should == "pdf-upload.pdf"
      @uploader.current_path.should include "/uploads/", "/test_env/", "/attachments/", "/pdf-upload.pdf", "/#{@attachment.id}/"
    end
    its('file.content_type') { should include "/pdf" }
    describe "#thumb" do
      subject { @uploader.thumb }
      it "should have the correct size (pixels)" do
        subject.should be_no_larger_than(100,100)
      end
    end
  end
end
