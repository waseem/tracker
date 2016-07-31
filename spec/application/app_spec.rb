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

  describe '/dashboard' do
    it 'renders dashboard template' do
      get '/dashboard'

      expect(last_response).to be_ok
      expect(last_response.body).to include("Jobs to be Processed")
      expect(last_response.body).to include("Total Processed Jobs")
      expect(last_response.body).to include("Failed Jobs")
      expect(last_response.body).to include("Successfully Processed Jobs")
      expect(last_response.body).to include("Cache")
    end
  end

  describe "/:shortlink" do
    context "queue is available" do
      it "enqueues the parameters and headers for processing" do
        expect(Resque).to receive(:enqueue).with(PostProcessorQueue, /\"shortlink\": \"nonexisting\"/, /\"REQUEST_METHOD\": \"GET\"/).once

        get "/nonexisting"

        expect(last_response).to be_redirect
        expect(last_response.location).to eq("http://sharepop.com")
      end
    end

    context "queue is unavailable" do
      it "enqueues the parameters and headers for processing after retrying" do
        allow(Resque).to receive(:enqueue).with(PostProcessorQueue, /\"shortlink\": \"nonexisting\"/, /\"REQUEST_METHOD\": \"GET\"/).once.and_raise(Redis::CannotConnectError)
        expect(Resque).to receive(:enqueue).with(PostProcessorQueue, /\"shortlink\": \"nonexisting\"/, /\"REQUEST_METHOD\": \"GET\"/).and_return(true)

        get "/nonexisting"

        expect(last_response).to be_redirect
        expect(last_response.location).to eq("http://sharepop.com")
      end
    end
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
        shortlink = Shortlink.create!(slug: "slug1", campaign: campaign)

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
        shortlink = Shortlink.create!(slug: "slug2", campaign: campaign)

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
