require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'boot')
require 'database'

data_dir = File.join(File.expand_path(File.dirname(__FILE__)), '..', 'data')

# Following reads entire JSON files in the memory. It's very inefficient for large files. In case there are large JSON files, a library like json-stream or yajl should be used.
#
campaigns_json = ActiveSupport::JSON.decode(File.read(File.join(data_dir, 'campaigns.json')))
campaigns_json.each do |campaign|
  Campaign.create!(name:        campaign["name"],
                   status:      campaign["status"],
                   offer_url:   campaign["offer_url"],
                   preview_url: campaign["preview_url"]
                  )
end

shortlinks_json = ActiveSupport::JSON.decode(File.read(File.join(data_dir, 'shortlinks.json')))

shortlinks_json.each do |shortlink|
  Shortlink.create!(campaign_id: shortlink["campaign_id"], slug: shortlink["slug"],)
end
