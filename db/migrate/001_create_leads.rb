class CreateLeads < ActiveRecord::Migration
  def self.up
    create_table :leads do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :company
      t.string :title
      t.string :cell
      t.string :office_phone
      t.string :website
      t.string :source

      t.timestamps
    end
  end

  def self.down
    drop_table :leads
  end
end
