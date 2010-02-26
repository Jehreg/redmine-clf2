class LanguageSwitcherController < ApplicationController
  unloadable

  def french
    logger.debug "Setting french"
    session[:language] = 'fr'
    if request.referer
      redirect_to request.referer
    else
      redirect_back_or_default('/')
    end
  end
  
  def english
    logger.debug "Setting english"
    session[:language] = 'en'
    if request.referer
      redirect_to request.referer
    else
      redirect_back_or_default('/')
    end
  end

  private

  # Override the ApplicationController method so any user can access
  # these methods, no matter what setting is picked.
  def check_if_login_required
    false
  end
end
