require 'spec_helper'

describe CacheStoreExtension do

  describe "#renew" do
    before do
      Rails.cache.clear
      @cache_key = "foo"
      @old_value = "old_value"
      @new_value = Time.zone.now
    end
    subject {
      Rails.cache.renew do
        Rails.cache.fetch(@cache_key) { @new_value }
      end
    }

    describe "when the value has not been cached before" do
      it "should save the new value in the cache" do
        Rails.cache.read(@cache_key).should == nil
        subject
        Rails.cache.read(@cache_key).should == @new_value
      end
    end

    describe "when the value has been cached before, but with a different value" do
      before { Rails.cache.write(@cache_key, @old_value) }
      it "should save the new value in the cache" do
        Rails.cache.read(@cache_key).should == @old_value
        subject
        Rails.cache.read(@cache_key).should == @new_value
      end
      specify "but without 'renew' the cached value should be returned by 'fetch' without renewal" do
        Rails.cache.fetch(@cache_key) { @new_value }.should == @old_value
      end
    end

    describe "for dependent values" do
      before { @helper_cache_key = "#{@cache_key}-helper" }
      subject {
        Rails.cache.renew do
          Rails.cache.fetch(@cache_key) { Rails.cache.fetch(@helper_cache_key) { @new_value }.to_i * 2 }
        end
      }

      describe "when an old value is present" do
        before { Rails.cache.fetch(@cache_key) { Rails.cache.fetch(@helper_cache_key) { @old_value }.to_i * 2 } }

        it "should renew the value" do
          Rails.cache.read(@cache_key).should == @old_value.to_i * 2
          subject
          Rails.cache.read(@cache_key).should == @new_value.to_i * 2
        end
        it "should also renew the helper value on which the value depends" do
          Rails.cache.read(@helper_cache_key).should == @old_value
          subject
          Rails.cache.read(@helper_cache_key).should == @new_value
        end
      end
    end
  end

end