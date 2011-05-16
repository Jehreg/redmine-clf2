ActionController::Routing::Routes.draw do |map|
  map.english 'english', :controller => 'language_switcher', :action => 'english'
  map.french 'french', :controller => 'language_switcher', :action => 'francais'
  map.anglais 'anglais', :controller => 'language_switcher', :action => 'english'
  map.francais 'francais', :controller => 'language_switcher', :action => 'francais'

  map.welcome '/welcome', :controller => 'welcome', :action => 'welcome'
  map.bienvenue '/bienvenue', :controller => 'welcome', :action => 'welcome'

  map.help '/help', :controller => 'application', :action => 'help'
  map.aide '/aide', :controller => 'application', :action => 'help'

  map.contact '/contact', :controller => 'application', :action => 'contact'
  map.contactez '/contactez', :controller => 'application', :action => 'contact'
end
