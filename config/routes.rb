ActionController::Routing::Routes.draw do |map|
  map.welcome '/welcome', :controller => 'welcome', :action => 'welcome'
  map.bienvenue '/bienvenue', :controller => 'welcome', :action => 'welcome'

  map.help '/help', :controller => 'application', :action => 'help'
  map.aide '/aide', :controller => 'application', :action => 'help'

  map.contact '/contact', :controller => 'application', :action => 'contact'
  map.contactez '/contactez-nous', :controller => 'application', :action => 'contact'
end
