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

  create_table "cdrs", :force => true do |t|
    t.string   "callid"
    t.string   "remotename"
    t.string   "remotenum"
    t.datetime "callstart"
    t.datetime "callend"
    t.string   "direction"
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

  create_table "contacts", :force => true do |t|
    t.string   "number"
    t.integer  "basecampid"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "current_calls", :force => true do |t|
    t.string   "number"
    t.string   "callerid"
    t.datetime "duration"
    t.integer  "basecampid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "leads", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "company"
    t.string   "title"
    t.string   "cell"
    t.string   "office_phone"
    t.string   "website"
    t.string   "source"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "highrise_lead_id"
  end

# Could not dump table "linkedin_connections" because of following StandardError
#   Unknown type '' for column 'First Name'

  create_table "localcaches", :force => true do |t|
    t.integer  "basecampid"
    t.string   "name"
    t.string   "cellnumber"
    t.string   "officenumber"
    t.string   "homenumber"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "servers", :force => true do |t|
    t.string   "host"
    t.string   "port"
    t.string   "call_client"
    t.string   "password"
    t.string   "user_uid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.string   "bs_id"
    t.string   "userUid"
    t.string   "offhook"
    t.string   "numcalls"
    t.integer  "maxcalls"
    t.boolean  "epControl"
    t.boolean  "bPhone"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

# Could not dump table "von_spring_pre" because of following StandardError
#   Unknown type '' for column 'First Name'

end
