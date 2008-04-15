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

  c = Call.find_by_callid(info["callId"])
  if c.nil?
    c = Call.new
    c.user = info["user"][0] unless info["user"].nil?
    c.remote_country_code = info["remoteCountryCode"][0] unless info["remoteCountryCode"].nil?
    c.personality = info["personality"][0] unless info["personality"].nil?
    c.callid = info["callId"]
    c.calltype = info["callType"][0] unless info["callType"].nil?
    c.release_cause = info["releaseCause"][0] unless info["releaseCause"].nil?
    c.remote_number = info["remoteNumber"][0] unless info["remoteNumber"].nil?
    c.appearance = info["appearance"][0] unless info["appearance"].nil?
    c.extTrackingid = info["extTrackingId"]
    c.remote_name = info["remoteName"][0] unless info["remoteName"].nil?
    c.state = info["state"][0] unless info["state"].nil?
    c.save
  else
    case info["state"][0]
      when "5"
        c.destroy
      else
        c.state = info["state"][0]
        c.save
    end
  end
}
bs.follow "thowe1@broadsoft.com"
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

