class WelcomeController < ApplicationController
  caches_action :robots

  def index 
    if session[:language]
      @news = News.latest User.current
      @projects = Project.latest User.current
    else
      render :action => 'welcome', :layout => 'wp-pa' 
    end
  end

  def welcome
    render :layout => 'wp-pa' 
  end
  
  def robots
    @projects = Project.all_public.active
    render :layout => false, :content_type => 'text/plain'
  end
end
