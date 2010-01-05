ActionController::Routing::Routes.draw do |map|
  map.english 'english', :controller => 'language_switcher', :action => 'english'
  map.french 'french', :controller => 'language_switcher', :action => 'french'
end
