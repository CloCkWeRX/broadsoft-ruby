class CreateLocalcaches < ActiveRecord::Migration
  def self.up
    create_table :localcaches do |t|
      t.integer :basecampid
      t.string :name
      t.string :cellnumber
      t.string :officenumber
      t.string :homenumber
      t.string :email

      t.timestamps
    end
  end

  def self.down
    drop_table :localcaches
  end
end
