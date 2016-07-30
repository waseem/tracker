require 'spec_helper'

RSpec.describe Campaign do
  describe "#active?" do
    context "status is active" do
      it 'is true' do
        
        campaign = Campaign.create!(name: "Aura", status: "active", offer_url: "http://i.imgur.com/TIuaCAW.jpg", preview_url: "http://imgur.com/TIuaCAW")

        expect(campaign.active?).to eq(true)
      end
    end

    context "status is anything but active" do
      it 'is false' do
        campaign = Campaign.create!(name: "Aura", status: "expired", offer_url: "http://i.imgur.com/TIuaCAW.jpg", preview_url: "http://imgur.com/TIuaCAW")

        expect(campaign.active?).to eq(false)
      end
    end
  end
end
