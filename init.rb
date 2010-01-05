require 'redmine'

Redmine::Plugin.register :redmine_clf2 do
  name 'Redmine IRCan plugin'
  author 'Patrick Naubert'
  description 'This is a plugin for Redmine to insert the GoC CLF2 constraints.'
  version '0.9.0'

  permission(:change_language, {:language_switcher => [:french, :english]}, :public => true)
  settings(:default => {
             'welcome_text_fr' => ''
           })
end

require 'clf2/hooks/project_hooks'
require 'clf2/hooks/administration_settings_hooks'

# Patches to the Redmine core
require "dispatcher"
require 'clf2_application_controller_patch'
require 'clf2_projects_controller_patch'
require 'clf2_principal_patch'


Dispatcher.to_prepare :redmine_clf2_patches do
  begin
    require_dependency 'application'
  rescue LoadError
    require_dependency 'application_controller' # Rails 2.3
  end
  require_dependency 'principal'
  require_dependency 'user'
  require_dependency 'setting'

  ApplicationController.send(:include, Clf2::ApplicationController::Patch)
  ProjectsController.send(:include, Clf2::ProjectsController::Patch)
  Principal.send(:include, Clf2::Principal::Patch)
  User.send(:include, Clf2::Principal::Patch)
  Project.send(:include, Clf2::Patches::ProjectPatch)
  Setting.send(:include, Clf2::Patches::SettingPatch)
end

