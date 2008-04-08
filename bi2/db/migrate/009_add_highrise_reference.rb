class AddHighriseReference < ActiveRecord::Migration
  def self.up
    add_column :leads, :highrise_lead_id, :integer 
  end

  def self.down
    remove_column :leads, :highrise_lead_id
  end
end
