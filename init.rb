require 'redmine'

unless Redmine::Plugin.registered_plugins.keys.include?(:redmine_w3h)
  Redmine::Plugin.register :redmine_clf2 do
    name 'Redmine CLF2 plugin'
    author 'Patrick Naubert'
    description 'This plugin implements the GoC Web Experience Toolkit CLF2 theme for Redmine'
    version '0.9.0'

    permission(:change_language, {:language_switcher => [:french, :english]}, :public => true)
    settings(:default => {
               'welcome_text_fr' => ''
             })

    menu :top_menu, :my_account, '/my/account', :caption => :label_my_account
  end
end


# Patches to the Redmine core
require "dispatcher"
Dispatcher.to_prepare :redmine_clf2_patches do
  next if ApplicationController.included_modules.include? RedmineClf2::Patches::ApplicationControllerPatch

  require_dependency 'application_controller'
  require 'redmine_clf2/patches/application_controller_patch'
  ApplicationController.send(:include, RedmineClf2::Patches::ApplicationControllerPatch)

  require_dependency 'principal'
  require 'redmine_clf2/patches/principal_patch'
  Principal.send(:include, RedmineClf2::Patches::PrincipalPatch)

  require_dependency 'project'
  require 'redmine_clf2/patches/project_patch'
  Project.send(:include, RedmineClf2::Patches::ProjectPatch)

  require_dependency 'projects_controller'
  require 'redmine_clf2/patches/projects_controller_patch'
  ProjectsController.send(:include, RedmineClf2::Patches::ProjectsControllerPatch)

  require_dependency 'setting'
  require 'redmine_clf2/patches/setting_patch'
  Setting.send(:include, RedmineClf2::Patches::SettingPatch)

  require_dependency 'settings_helper'
  require 'redmine_clf2/patches/settings_helper_patch'
  SettingsHelper.send(:include, RedmineClf2::Patches::SettingsHelperPatch)
end

require 'redmine_clf2/hooks/administration_settings_hooks'
require 'redmine_clf2/hooks/project_hooks'
