module Clf2
  module Hooks
    class AdministrationSettingHooks < Redmine::Hook::ViewListener
      def view_settings_general_form(context={})
        content = ''
        content << content_tag(:label, l(:setting_welcome_text_fr))
        content << text_area_tag('settings[plugin_redmine_clf2][welcome_text_fr]', Setting.plugin_redmine_clf2['welcome_text_fr'], :cols => 60, :rows => 5, :class => 'wiki-edit')
        content << javascript_tag("var FRwikiToolbar = new jsToolBar($('settings_plugin_redmine_clf2_welcome_text_fr')); FRwikiToolbar.draw();")
        
        return content_tag(:p, content)
      end
    end
  end
end
