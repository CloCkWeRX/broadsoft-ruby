class CreateCalls < ActiveRecord::Migration
  def self.up
    create_table :calls do |t|
      t.string :user
      t.string :bs_id
      t.string :userUid
      t.string :callid
      t.string :extTrackingid
      t.string :callCenterUserId
      t.integer :state
      t.integer :appearance
      t.integer :personality
      t.integer :calltype
      t.string :release_cause
      t.boolean :remote_country_code
      t.string :remote_number
      t.string :remote_name

      t.timestamps
    end
  end

  def self.down
    drop_table :calls
  end
end
