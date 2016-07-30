require 'spec_helper'
require 'cache'

RSpec.describe Cache do
  before(:each) do
    @hasher = Object.new
    def @hasher.hash(key); key; end

    @logger = Object.new
    def @logger.info(message); message; end
    @cache = Cache.new(@hasher, @logger)
  end

  describe "#get and #store" do
    context "object is present" do
      it 'returns object' do
        @cache.store('some_key', 'some_value')
        expect(@cache.get('some_key')).to eq('some_value')
      end
    end

    context "object is absent" do
      it 'returns nil' do
        expect(@cache.get('some_key')).to eq(nil)
      end
    end
  end

  describe "#fetch" do
    context "object is already present" do
      context "object is stale" do
        it 'updates the value' do
          one_minute_before_now = Time.now - 60
          @cache.store('some_key', { 
            '_object' => 'some_value',
            'expire_at' => one_minute_before_now
          })

          value = @cache.fetch('some_key') { 'other_value' }

          expect(value).to eq('other_value')
          expect(@cache.get('some_key')['expire_at']).to be > one_minute_before_now
        end
      end

      context "object is fresh" do
        it 'returns the cached object' do
          one_minute_from_now = Time.now + 60
          @cache.store('some_key', { 
            '_object' => 'some_value',
            'expire_at' => one_minute_from_now
          })
          value = @cache.fetch('some_key') { 'other_value' }
          expect(value).to eq('some_value')
          expect(@cache.get('some_key')['expire_at']).to be <= one_minute_from_now
        end
      end
    end

    context "object is absent initially" do
      it 'returns object' do
        expect(@cache.fetch('some_key') { 'other_value' }).to eq('other_value')
        expect(@cache.get('some_key')['_object']).to eq('other_value')
        expect(@cache.get('some_key')['expire_at']).not_to eq(nil)
      end
    end
  end

  describe "#is_fresh?" do
    context "expire_at is absent in cached object" do
      it 'is nil' do
        #one_minute_before_now = Time.now - 60
        value = { '_object' => 'some_value' }
        expect(@cache.is_fresh?(value)).to eq(nil)
      end
    end

    context "expire_at is in future" do
      it 'is true' do
        one_minute_from_now = Time.now + 60
        value = { '_object' => 'some_value', 'expire_at' => one_minute_from_now }
        expect(@cache.is_fresh?(value)).to eq(true)
      end
    end

    context "expire_at is in past" do
      it 'is false' do
        one_minute_before_now = Time.now - 60
        value = { '_object' => 'some_value', 'expire_at' => one_minute_before_now }
        expect(@cache.is_fresh?(value)).to eq(false)
      end
    end
  end
end
