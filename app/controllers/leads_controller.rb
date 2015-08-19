class LeadsController < ApplicationController
  # GET /leads
  # GET /leads.xml
  def index
    @leads = Lead.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @leads }
    end   
  end

   
  def get_inbox_status
    @result = Time.now.to_s + " from the server"
    render :layout => false     
  end
  
  def preview 
    @search_text  = params[:search].strip
    unless params[:search].blank? 
     @leads = Lead.find(:all, :conditions => ["first_name like ? OR last_name like ? OR company like ? or title like ?", 
       @search_text + "%", @search_text + "%", @search_text + "%", @search_text + "%"])
    end
    render :layout => false 
  end
  
  def search 
    unless params[:search].blank? 
      @lead_pages, @leads = paginate :leads, 
      :per_page => 10, 
      :order => order_from_params, 
      :conditions => Lead.conditions_by_like(params[:search]) 
      logger.info @leads.size 
    else 
      list 
    end 
      render :partial=>'search', :layout=>false 
   end 

  def search_demo
    @leads = Lead.find(:all)       
  end
  

  def list
    @leads = Lead.find(:all)   
  end
  
  # GET /leads/1
  # GET /leads/1.xml
  def show
    @lead = Lead.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @lead }
    end
  end

  # GET /leads/new
  # GET /leads/new.xml
  def new
    @lead = Lead.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @lead }
    end
  end

  # GET /leads/1/edit
  def edit
    @lead = Lead.find(params[:id])
  end

  # POST /leads
  # POST /leads.xml
  def create
    @lead = Lead.new(params[:lead])

    respond_to do |format|
      if @lead.save
        flash[:notice] = 'Lead was successfully created.'
        format.html { redirect_to(@lead) }
        format.xml  { render :xml => @lead, :status => :created, :location => @lead }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @lead.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /leads/1
  # PUT /leads/1.xml
  def update
    @lead = Lead.find(params[:id])

    respond_to do |format|
      if @lead.update_attributes(params[:lead])
        flash[:notice] = 'Lead was successfully updated.'
        format.html { redirect_to(@lead) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @lead.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /leads/1
  # DELETE /leads/1.xml
  def destroy
    @lead = Lead.find(params[:id])
    @lead.destroy

    respond_to do |format|
      format.html { redirect_to(leads_url) }
      format.xml  { head :ok }
    end
  end
end
