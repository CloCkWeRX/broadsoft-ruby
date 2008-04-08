class CreateCurrentCalls < ActiveRecord::Migration
  def self.up
    create_table :current_calls do |t|
      t.string :number
      t.string :callerid
      t.timestamp :duration
      t.integer :basecampid

      t.timestamps
    end
  end

  def self.down
    drop_table :current_calls
  end
end
