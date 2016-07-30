require File.join(File.expand_path(File.dirname(__FILE__)), '..', '..', 'app', 'app')
require 'spec_helper'
require 'rack/test'

describe "Tracker Application" do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  describe "/" do
    it "redirects to sharepop" do
      get '/'
      expect(last_response).to be_redirect
      expect(last_response.location).to eq("http://sharepop.com")
    end
  end

  describe "/:shortlink" do
    context "shortlin is absent" do
      it "redirects to sharepop" do
        get "/nonexisting"

        expect(last_response).to be_redirect
        expect(last_response.location).to eq("http://sharepop.com")
      end
    end

    context "campaign is inactive" do
      it "redirects to sharepop" do
        campaign = Campaign.create!(name: "Aura", status: "expired", offer_url: "http://i.imgur.com/TIuaCAW.jpg")
        shortlink = Shortlink.create!(slug: "testing", campaign: campaign)

        get "/#{shortlink.id}"
        expect(last_response).to be_redirect
        expect(last_response.location).to eq("http://sharepop.com")

        get "/#{shortlink.slug}"
        expect(last_response).to be_redirect
        expect(last_response.location).to eq("http://sharepop.com")
      end
    end

    context "campaign is valid" do
      it "redirects to offer url" do
        campaign = Campaign.create!(name: "Aura", status: "active", offer_url: "http://i.imgur.com/TIuaCAW.jpg")
        shortlink = Shortlink.create!(slug: "testing", campaign: campaign)

        get "/#{shortlink.id}"
        expect(last_response).to be_redirect
        expect(last_response.location).to eq(campaign.offer_url)

        get "/#{shortlink.slug}"
        expect(last_response).to be_redirect
        expect(last_response.location).to eq(campaign.offer_url)
      end
    end
  end
end
