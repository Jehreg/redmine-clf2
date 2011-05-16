class LanguageSwitcherController < ApplicationController
  unloadable

  def francais
    session[:language] = 'fr'
    redirect_to :controller => 'welcome', :action => 'index'
  end
  
  def english
    session[:language] = 'en'
    redirect_to :controller => 'welcome', :action => 'index'
  end

  private

  # Override the ApplicationController method so any user can access
  # these methods, no matter what setting is picked.
  def check_if_login_required
    false
  end
end
