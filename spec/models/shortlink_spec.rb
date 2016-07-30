require 'spec_helper'

RSpec.describe Shortlink do
  describe "#has_active_campaign?" do
    context "no associated campaign"  do
      it "is false" do
        shortlink = Shortlink.create!(slug: "testing")

        expect(shortlink.has_active_campaign?).to eq(false)
      end
    end

    context "associated campaign is inacative" do
      it "is false" do
        campaign = Campaign.create!(name: "Aura", status: "expired", offer_url: "http://i.imgur.com/TIuaCAW.jpg")
        shortlink = Shortlink.create!(slug: "testing", campaign: campaign)

        expect(shortlink.has_active_campaign?).to eq(false)
      end
    end

    context "associated campaign is active" do
      it 'is true' do
        campaign = Campaign.create!(name: "Aura", status: "active", offer_url: "http://i.imgur.com/TIuaCAW.jpg")
        shortlink = Shortlink.create!(slug: "testing", campaign: campaign)

        expect(shortlink.has_active_campaign?).to eq(true)
      end
    end
  end
end
