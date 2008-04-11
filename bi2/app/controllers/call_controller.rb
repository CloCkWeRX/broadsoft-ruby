
class CallController < ApplicationController
  
  def index
  end
  def get_call_status
    puts session[:display_info]
    if session[:display_info].nil?
      session[:display_info] = "idle"
    end
    @result = "Not currently in call"
    c = Call.find(:first, :order => "created_at DESC")
    unless c.nil?
      case c.state
       when 1..2
        @result = "Currently in call with #{c.remote_number}"
        @in_call = true
        if session[:display_info] == "display"  
          session[:display_info] = "displayed" 
        end
        if session[:display_info] == "onhook"
          # only should happen once

          # Set the flag in the session to display the information
          session[:display_info] = "display"                  
          l = Lead.find(:first, :conditions => ["cell like ?", "%#{c.remote_number}"]) 
        
          unless l.nil?
            session[:highrise_path] = "http://thomashowe.highrisehq.com/people/#{l.highrise_lead_id}"
            session[:person_name] = "#{l.first_name} #{l.last_name}"
            session[:unkown_name] = false
          else
            session[:highrise_path] = "http://www.whitepages.com/search/ReversePhone?full_phone=#{c.remote_number}&localtime=survey"
            session[:person_name] = "Unknown"
            session[:unkown_name] = true
          end
        end        
      end
    end
  end
  def dial
    c = Command.new
    c.command = "dial"
    c.additional_data = params[:id]
    c.save
  end
end
