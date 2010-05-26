module RedmineClf2
  module Patches
    module SettingsHelperPatch
      def self.included(base)
        base.class_eval do
          unloadable
          
          # Patch setting_text_area so when it's used with the :welcome_text in
          # French, the correct English values are entered into the field.
          def setting_text_area_with_english_french_welcome_text(setting, options={})
            if setting == :welcome_text && current_language == :fr
              setting_label(setting, options) +
                text_area_tag("settings[#{setting}]", Setting.english_welcome_text, options)

            else
              setting_text_area_without_english_french_welcome_text(setting, options)
            end
          end

          alias_method_chain :setting_text_area, :english_french_welcome_text
        end
      end
    end
  end
end
