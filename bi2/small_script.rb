#!/usr/bin/env ruby -wKU
# Copyright (c) 2007, The Thomas Howe Company, All Rights Reserved
# Original Author : Thomas Howe
#
#
require "broadsoft.rb"
  

bs = Broadworks.new("64.215.212.65", "2208", "2413333852@64.215.212.60", true)
bs.assign_call_function { |info|
  puts "Just got a call"
  p info
}
bs.assign_session_function { |info|
  puts "Just got a session message"
  p info
}
bs.assign_profile_function { |info|
  puts "Just got a profile message"
  p info
}
# bs.dial "3852"

sleep 3600
