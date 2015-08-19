
class CallController < ApplicationController
  
  def index
    if session[:user_login].nil?
      redirect_to :action => :login
    end
    
  end
  def get_call_status
    if session[:user_login].nil?
      redirect_to :action => :login
    end
    @result = "Not currently in call"
    c = Call.find_by_user(session[:user_login])
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
          l = Lead.find(:first, :conditions => ["cell like ? or office_phone like ?", "%#{c.remote_number[-10,10]}", "%#{c.remote_number[-10,10]}"]) 
        
          unless l.nil?
            session[:highrise_path] = "http://thomashowe.highrisehq.com/people/#{l.highrise_lead_id}"
            session[:person_name] = "#{l.first_name} #{l.last_name}"
            session[:unknown_name] = false
          else
            session[:highrise_path] = "http://www.whitepages.com/search/ReversePhone?full_phone=#{c.remote_number}&localtime=survey"
            session[:person_name] = "Unknown"
            session[:unkown_name] = true
          end
        end        
      end
    else
      session[:display_info] = "onhook"       
    end
  end
  def dial
    c = Command.new
    c.command = "dial"
    c.additional_data = params[:id]
    c.save
  end
  def start
    session[:user_login] = params[:user]
    c = Command.new
    c.command = "follow"
    c.additional_data = params[:user]
    c.save
    redirect_to :action => :index 
  end
  def logout
    session[:user_login] = nil
    c = Command.new
    c.command = "drop"
    c.additional_data = params[:user]
    c.save
    redirect_to :action => :login 
  end
end
