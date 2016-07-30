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
      it 'returns object' do
        @cache.store('some_key', 'some_value')
        expect(@cache.fetch('some_key') { 'other_value' }).to eq('some_value')
      end
    end

    context "object is absent initially" do
      it 'returns object' do
        expect(@cache.fetch('some_key') { 'other_value' }).to eq('other_value')
        expect(@cache.get('some_key')).to eq('other_value')
      end
    end
  end
end
