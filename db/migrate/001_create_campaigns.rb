class CreateCampaigns < ActiveRecord::Migration
  def change
    create_table :campaigns do |t|
      t.string :name, null: false
      t.string :status
      t.string :offer_url
      t.string :preview_url

      t.timestamps null: false
    end
  end
end
