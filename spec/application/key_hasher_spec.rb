require 'spec_helper'
require 'key_hasher'

RSpec.describe KeyHasher do
  describe ".hash" do
    it 'hashes the key with md5' do
      expect(KeyHasher.hash('some')).to eq(Digest::MD5.hexdigest('some'))
    end
  end
end
