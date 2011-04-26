ActionController::Routing::Routes.draw do |map|
  map.english 'english', :controller => 'language_switcher', :action => 'english'
  map.french 'french', :controller => 'language_switcher', :action => 'french'
  map.help '/help', :controller => 'application', :action => 'help'
  map.aide '/aide', :controller => 'application', :action => 'help'
  map.contact '/contact', :controller => 'application', :action => 'contact'
end
