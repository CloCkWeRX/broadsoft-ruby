# Thomas S. Howe wrote it, but the world owns it. Have at it.
#
# Original Author : Thomas Howe, http://www.thomashowe.com
#
#

require 'rubygems'
require 'sqlite3'
require "broadsoft.rb"
require 'net/http' 
require 'active_record' 

# connect to database.  This will create one if it doesn't exist
if ARGV[0].nil? or ARGV[0].empty?
  MY_DB_NAME = "db/development.sqlite3" 
else
  MY_DB_NAME = ARGV[0]
end
puts "Using database #{MY_DB_NAME}"
#MY_DB = SQLite3::Database.new(MY_DB_NAME)

# get active record set up
ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => MY_DB_NAME)

# Now create your AR class
class Call < ActiveRecord::Base 
end 

class Command < ActiveRecord::Base
end

logger = Logger.new(STDOUT)

# Startup the Broadworks stack.
bs = Broadworks.new("ews.ihs.broadsoft.com", "2208", "thowe1@broadsoft.com", "Password1", false, logger)

bs.assign_call_function { |info|
  # We need to put this information into the database.  Let's try that, shall we?

  p info
  
  c = Call.find_by_callid(info["call"][0]["callId"])
  if c.nil?
    c = Call.new
    c.user = info["monitoredUserId"][0] unless info["monitoredUserId"][0].nil?
    c.remote_number = info["call"][0]["remoteNumber"][0] unless info["call"][0]["remoteNumber"].nil?
    c.callid = info["call"][0]["callId"]
    c.calltype = info["call"][0]["callType"][0] unless info["call"][0]["callType"].nil?
    c.extTrackingid = info["call"][0]["extTrackingId"]
    c.remote_name = info["call"][0]["remoteName"][0] unless info["call"][0]["remoteName"].nil?
    c.state = info["call"][0]["state"][0] unless info["call"][0]["state"].nil?
    c.save
  else
    case info["call"][0]["state"][0]
      when "5"
        c.destroy
      else
        c.state = info["call"][0]["state"][0]
        c.save
    end
  end
}

bs.follow "mlauricella@broadsoft.com"
bs.follow "tradeshow1@broadsoft.com"
#bs.dial "15083649972"
puts "Broadsoft application running. Press CTL-C to exit"
trap "SIGINT", proc {
  puts "Control C Caught.... Now exiting...\n"
  exit
}

while true
  sleep 1
  # Look in the database for commands to issue
  cmds = Command.find(:all)
  cmds.each { |c|
    case c.command 
    when "dial"
      bs.dial c.additional_data
    when "redial"
      bs.redial 
    when "answer"
      bs.answer c.call_id 
    when "release"
      bs.release c.call_id 
    when "hold"
      bs.hold c.call_id 
    end
    c.destroy    
  } 
end

