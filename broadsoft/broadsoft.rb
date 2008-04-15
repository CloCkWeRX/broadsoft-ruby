# This file contains the Ruby library for the Broadworks ruby gem.  Boadworks
# is an application from Broadsoft that supplies call features to voice over IP
# carriers.  For more information on Broadsoft projects, visit http://www.broadsoft.com. 
# This gem can be used to implement telco 2.0 features such as click-to-call, decision
# support applications and third party call control.  For more information about applications
# you can build with this gem,  please visit http://www.thomashowe.com.
#
#
# Example Application
=begin rdoc
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
  MY_DB = SQLite3::Database.new(MY_DB_NAME)

  # get active record set up
  ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => MY_DB_NAME)

  # Now create your AR class
  class Call < ActiveRecord::Base 
  end 

  class Command < ActiveRecord::Base
  end

  # Startup the Broadworks stack.
  bs = Broadworks.new("xxxxxx.com", "2208", "thowe1@broadsoft.com", "yyyyyy")

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
  
=end

#--
# Copyright (c) 2008, The Thomas Howe Company, All Rights Reserved
# Original Author : Thomas Howe
#++
#

require "rubygems"
require "xmlsimple"
require "rexml/document"
require 'net/telnet'
require 'digest/md5'
require 'digest/sha1'
require 'logger'

=begin rdoc
  This is the main class for the library.  I've only tested this with one instance running, although I 
  cannot see any other reason that it shouldn't work.
  
  Example of use:
   require 'rubygems'
   require "broadsoft.rb"

   # Startup the Broadworks stack.
   bs = Broadworks.new("xxxxxxx.com", "2208", "thowe1@broadsoft.com", "yyyyyy")
  
   
=end
class Broadworks < Object
  attr_accessor :host, :port, :call_client, :default_handler, :debug_print, :password, :logger, :current_calls
  
=begin rdoc
  The initialization function. Host refers to the IP address of the broadworks OCS, port to it's 
  control port. call_client and password are assigned to the user we are monitoring.
=end
  def initialize(host, port, call_client, password, call_control = true, logger=nil) 
    @host, @port, @call_client, @password, @call_control = host, port, call_client, password, call_control

    if logger.nil?
      logger = Logger.new(STDOUT)
      logger.level = Logger::WARN
    end    
    @logger = logger

    logger.info "Program started"
    logger.info "Running in call control mode" if @call_control
    logger.info "Running in attendant mode" unless @call_control
    
    
    @t = TCPSocket::new(@host, @port)
    logger.info "Initializing system"
    send init_script
    response = getResponse
    securePassword = calcPass(response)
    send response_script(securePassword)
    response = getResponse
    @user_uid = getUserUid(response)
    send ack_script(@user_uid)

    logger.info "Entering thread"
    pid  = Thread.new do 
      while true do
        msg = getResponse
        dispatchMsg msg
      end
    end
  end 
  
   def calcPass response  
    data = XmlSimple.xml_in(response)
    nonce = data["command"][0]["commandData"][0]["nonce"][0]

    f1 = Digest::SHA1.hexdigest(@password)
    f2 = nonce + ":" + f1
    Digest::MD5.hexdigest(f2)    
  end
  
  def getUserUid(response)
    data = XmlSimple.xml_in(response)
    uid = data["command"][0]["commandData"][0]["user"][0]["userUid"]
  end
  
  def getResponse
    response=""
    message_received = false
    until message_received  do
    	response << @t.recvfrom(1).to_s
        if response.include? "<\/BroadsoftDocument>"
    		  message_received=true
    	  end
    end
    logger.info "Message received at #{Time.now}"
    
    # This code runs wether or not there's a debug level that needs it.
    # For simplicity, I'm leaving it in, but it may be unnecessary
    doc = REXML::Document.new response
    output = ""        
    doc.write( output, 0 )
    logger.info output
    response
  end
  
  def send message
    logger.info "Message sent at #{Time.now}"
    doc = REXML::Document.new message        
    output = ""        
    doc.write( output, 0 )
    logger.info output
    @t.send(message,0)
  end
  
  def loop
    while true do
      msg = getResponse
      dispatchMsg msg
    end
  end
  
  def dispatchMsg msg 
    logger.info "Message received at #{Time.now}"
   
    output = ""        
    doc = REXML::Document.new msg        
    doc.write( output, 0 )
    logger.info output
    message  = XmlSimple.xml_in(msg)
    
    case message["command"][0]["commandType"]
      when "callUpdate"      
        logger.info "Dispatching call update message"     
        info = message["command"][0]["commandData"][0]["user"][0]["call"][0]
        @call_function.call(info) unless @call_function.nil?  
           
      when "sessionUpdate"
        logger.info "Dispatching session message"     
        info = message["command"][0]["commandData"][0]["user"][0]
        @session_function.call(info) unless @session_function.nil?    
     
      when "profileUpdate"
        logger.info "Dispatching profile message"     
        info = message["command"][0]["commandData"][0]["user"][0]
        @profile_function.call(info) unless @profile_function.nil?
        
      when "monitoringUsersResponse"
        logger.info "Dispatching monitor message"     
        info = message["command"][0]["commandData"][0]["user"][0]
        @monitor_function.call(info) unless @monitor_function.nil?

      else
        puts "Whoa! What was that?"
      end
    logger.info "dispatchMsg done"   
  end
  
  
  def assign_call_function &action
    @call_function = action
  end
  
  def assign_profile_function &action
    @profile_function = action
  end
  def assign_session_function &action
    @session_function = action
  end  
  def monitor_function &action
    @monitor_function = action
  end
  
  # Commands
  def dial number
    raise "Cannot control a phone when in attendant console mode" unless @call_control
    send dial_script(number) 
  end
  def redial 
    raise "Cannot control a phone when in attendant console mode" unless @call_control
    send redial_script
  end
  def hold call_id
    raise "Cannot control a phone when in attendant console mode" unless @call_control
    send hold_script(call_id)
  end
  def answer call_id
    raise "Cannot control a phone when in attendant console mode" unless @call_control
    send answer_script(call_id)
  end
  def release call_id
    raise "Cannot control a phone when in attendant console mode" unless @call_control
    send release_script(call_id)
  end
  def follow user
    raise "Cannot control a phone when in control mode" if @call_control
    send follow_script(user)
  end
  def heartbeat
    send heartbeat_script
  end
  
  
  private 
  
  def init_script 
  msg = <<-STRING
  <?xml version="1.0" encoding="UTF-8"?> 
    <BroadsoftDocument protocol="CAP" version="14.0"> 
      <command commandType="registerAuthentication"> 
        <commandData> 
          <user userType="CallClient"> 
            <id>CALL_CLIENT</id> 
            <applicationId>THCApplication</applicationId> 
          </user> 
        </commandData> 
      </command> 
    </BroadsoftDocument>
  STRING
  msg.gsub!("CallClient", "AttendantConsole") unless @call_control
  msg.gsub("CALL_CLIENT",@call_client)
  end
  
  def response_script secure_password
  msg = <<-STRING 
  <?xml version="1.0" encoding="UTF-8"?> 
    <BroadsoftDocument protocol="CAP" version="14.0"> 
      <command commandType="registerRequest"> 
        <commandData> 
          <user userType="CallClient"> 
            <id>CALL_CLIENT</id>  
           <applicationId>THCApplication</applicationId> 
  		<securePassword>SECURE_PASSWORD</securePassword>
          </user> 
        </commandData> 
      </command> 
    </BroadsoftDocument> 
  STRING
  msg.gsub!("CallClient", "AttendantConsole") unless @call_control
  msg.gsub("CALL_CLIENT",@call_client).gsub("SECURE_PASSWORD",secure_password)
  end

  def ack_script user_uid
  msg = <<-STRING
  <?xml version="1.0" encoding="UTF-8"?> 
    <BroadsoftDocument protocol="CAP" version="14.0"> 
      <command commandType="acknowledgement"> 
        <commandData>
  		<user id="CALL_CLIENT" userType="CallClient" userUid="CALL_USER_UID"><id>CALL_CLIENT</id> 
            <message messageName="registerResponse"/> 
            <applicationId>THCApplication</applicationId> 
          </user> 
        </commandData> 
      </command> 
    </BroadsoftDocument>
  STRING
  msg.gsub!("CallClient", "AttendantConsole") unless @call_control  
  msg.gsub("CALL_CLIENT",@call_client).gsub("CALL_USER_UID", user_uid)
  end
  
  def heartbeat_script 
  msg = <<-STRING
  <?xml version="1.0" encoding="UTF-8"?> 
   <BroadsoftDocument protocol="CAP" version="14.0"> 
     <command commandType="serverStatusRequest"> 
       <commandData> 
         <user userType="CallClient" userUid="CALL_USER_UID"> 
           <applicationId>THCApplication</applicationId> 
         </user> 
       </commandData> 
     </command> 
   </BroadsoftDocument> 
  STRING
  msg.gsub!("CallClient", "AttendantConsole") unless @call_control  
  msg.gsub("CALL_CLIENT",@call_client).gsub("CALL_USER_UID", @user_uid)
  end
  

  def dial_script number
  msg = <<-STRING
  <?xml version="1.0" encoding="UTF-8"?> 
    <BroadsoftDocument protocol="CAP" version="14.0"> 
      <command commandType="callAction"> 
        <commandData> 
          <user userType="CallClient" userUid="CALL_USER_UID"> 
            <action actionType="Dial"> 
              <actionParam 
                actionParamName="Number">PHONE_NUMBER</actionParam> 
            </action> 
            <applicationId>THCApplication</applicationId> 
          </user> 
        </commandData> 
      </command> 
    </BroadsoftDocument> 
  STRING
  msg.gsub("PHONE_NUMBER",number).gsub("CALL_USER_UID",@user_uid)
  end
  
  def redial_script
  msg = <<-STRING
  <?xml version="1.0" encoding="UTF-8"?> 
    <BroadsoftDocument protocol="CAP" version="14.0"> 
      <command commandType="callAction"> 
        <commandData> 
          <user userType="CallClient" userUid="CALL_USER_UID"> 
            <action actionType="Redial"/> 
            <applicationId>THCApplication</applicationId> 
          </user> 
        </commandData> 
      </command> 
    </BroadsoftDocument> 
  STRING
  msg.gsub("CALL_USER_UID",@user_uid)
  end
 
  def hold_script call_id
  msg = <<-STRING
  <?xml version="1.0" encoding="UTF-8"?> 
    <BroadsoftDocument protocol="CAP" version="14.0"> 
      <command commandType="callAction"> 
        <commandData> 
          <user userType="CallClient" userUid="CALL_USER_UID"> 
            <action actionType="Hold"> 
             <actionParam 
                actionParamName="CallId">CALL_ID</actionParam> 
            </action> 
            <applicationId>THCApplication</applicationId> 
          </user> 
        </commandData> 
      </command> 
    </BroadsoftDocument> 
  STRING
  msg.gsub("CALL_USER_UID",@user_uid).gsub("CALL_ID",call_id)
  end
 
  def answer_script call_id
  msg = <<-STRING
  <?xml version="1.0" encoding="UTF-8"?> 
    <BroadsoftDocument protocol="CAP" version="14.0"> 
      <command commandType="callAction"> 
        <commandData> 
          <user userType="CallClient" userUid="CALL_USER_UID"> 
            <action actionType="Answer"> 
             <actionParam 
                actionParamName="CallId">CALL_ID</actionParam> 
            </action> 
            <applicationId>THCApplication</applicationId> 
          </user> 
        </commandData> 
      </command> 
    </BroadsoftDocument> 
  STRING
  msg.gsub("CALL_USER_UID",@user_uid).gsub("CALL_ID",call_id)
  end
  
  def release_script call_id
  msg = <<-STRING
  <?xml version="1.0" encoding="UTF-8"?> 
    <BroadsoftDocument protocol="CAP" version="14.0"> 
      <command commandType="callAction"> 
        <commandData> 
          <user userType="CallClient" userUid="CALL_USER_UID"> 
            <action actionType="Release"> 
             <actionParam 
                actionParamName="CallId">CALL_ID</actionParam> 
            </action> 
            <applicationId>THCApplication</applicationId> 
          </user> 
        </commandData> 
      </command> 
    </BroadsoftDocument> 
  STRING
  msg.gsub("CALL_USER_UID",@user_uid).gsub("CALL_ID",call_id)
  end
  
  def follow_script user
  msg = <<-STRING
  <?xml version="1.0" encoding="UTF-8"?> 
  <BroadsoftDocument protocol="CAP" version="14.0"> 
    <command commandType="monitoringUsersRequest"> 
      <commandData> 
        <user userType="AttendantConsole" userUid="CALL_USER_UID"> 
          <monitoring monType="Add"/> 
          <monUser>USER</monUser> 
          <applicationId>THCApplication</applicationId> 
        </user> 
      </commandData> 
    </command> 
  </BroadsoftDocument> 
  STRING
  msg.gsub("CALL_USER_UID",@user_uid).gsub("USER",user)
  end
  
  
  
end
