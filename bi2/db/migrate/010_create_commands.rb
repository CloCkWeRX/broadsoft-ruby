class CreateCommands < ActiveRecord::Migration
  def self.up
    create_table :commands do |t|
      t.string :command
      t.string :additional_data
      t.string :call_id

      t.timestamps
    end
  end

  def self.down
    drop_table :commands
  end
end
