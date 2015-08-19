# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 10) do

# Could not dump table "booth_staff" because of following StandardError
#   Unknown type '' for column 'First Name'

  create_table "calls", :force => true do |t|
    t.string   "user"
    t.string   "bs_id"
    t.string   "userUid"
    t.string   "callid"
    t.string   "extTrackingid"
    t.string   "callCenterUserId"
    t.integer  "state"
    t.integer  "appearance"
    t.integer  "personality"
    t.integer  "calltype"
    t.string   "release_cause"
    t.boolean  "remote_country_code"
    t.string   "remote_number"
    t.string   "remote_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

    create_table "commands", :force => true do |t|
    t.string   "command"
    t.string   "additional_data"
    t.string   "call_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end
  
end
