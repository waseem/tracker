class CreateShortlinks < ActiveRecord::Migration
  def change
    create_table :shortlinks do |t|
      t.belongs_to :campaign
      t.string     :slug
      t.timestamps null: false
    end
  end
end
