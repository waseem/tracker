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

  describe ".cacheable_object" do
    context "shortlink is not present" do
      it "returns nil" do
        expect(Shortlink.cacheable_object(1234567)).to eq(nil)
        expect(Shortlink.cacheable_object('nonexisting-slug')).to eq(nil)
      end
    end

    context "shortlink campaign is inactive" do
      it "returns nil" do
        campaign = Campaign.create!(name: "Aura", status: "expired", offer_url: "http://i.imgur.com/TIuaCAW.jpg")
        shortlink = Shortlink.create!(slug: "testing", campaign: campaign)

        expect(Shortlink.cacheable_object(shortlink.id)).to eq(nil)
        expect(Shortlink.cacheable_object(shortlink.slug)).to eq(nil)
      end
    end

    context "shortlink campaign is active" do
      it 'returns cacheable object' do
        campaign = Campaign.create!(name: "Aura", status: "active", offer_url: "http://i.imgur.com/TIuaCAW.jpg")
        shortlink = Shortlink.create!(slug: "testing", campaign: campaign)
        obj = {
          shortlink_id: shortlink.id,
          slug:         shortlink.slug,
          offer_url:    shortlink.campaign.offer_url
        }

        expect(Shortlink.cacheable_object(shortlink.id)).to eq(obj)
        expect(Shortlink.cacheable_object(shortlink.slug)).to eq(obj)
      end
    end
  end
end
