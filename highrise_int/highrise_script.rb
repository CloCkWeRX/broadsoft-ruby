ENV["SITE"]="http://b8818804ce3f703faa5471bdd3022807c5a80e98:X@thomashowe.highrisehq.com"
require 'highrise.rb'
require 'rubygems'
require 'sqlite3'
require 'activerecord'

# connect to database.  This will create one if it doesn't exist
if ARGV[0].nil? or ARGV[0].empty?
  MY_DB_NAME = "db/development.sqlite3" 
else
  MY_DB_NAME = ARGV[0]
end
puts "Using database #{MY_DB_NAME}"
MY_DB = SQLite3::Database.new(MY_DB_NAME)

# get active record set up
ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => MY_DB_NAME, :timeout => 5000)

# create your AR class
class Lead < ActiveRecord::Base

end

ActiveRecord::Base.logger = Logger.new(STDOUT) 

# First of all, read all the contacts from highrise.
contacts = Highrise::Person.find_all_across_pages

# Next, remove our local version of the data
leads = Lead.delete_all

contacts.each { |c|
  # This is simple: we replace each of the leads in our table with the 
  # data from highrise.
  lead = Lead.new
  lead.first_name = c.first_name.to_s
  lead.last_name = c.last_name.to_s
  lead.title = c.title.to_s
  c.contact_data.email_addresses.each { |email|
    email.address = lead.email.to_s
  }
  c.contact_data.phone_numbers.each { |phone|
    case phone.location
      when "Work"
        lead.office_phone = phone.number.to_s
      when "Mobile"
        lead.cell = phone.number.to_s
      end
  }
  lead.source = "Highrise"
  lead.highrise_lead_id = c.id
  
  # Get the company information as well.
  lead.company = ""
  lead.company = Highrise::Company.find(c.company_id).name.to_s  unless c.company_id.nil?
  
  lead.save  
}
  


