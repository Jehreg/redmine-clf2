# Patches for the Setting class
module Clf2
  module Patches
    module SettingPatch
      def self.included(base)
        base.extend ClassMethods
        base.class_eval do
          class << self
            alias :english_welcome_text :welcome_text
            # Wrap the welcome_text field so it will serve up the French or
            # English version based on the current language.  If the main
            # one that is requested isn't present, the alternative will be
            # returned.
            #
            # Need to use class_eval because of how the getter/setters
            # are defined.
            def welcome_text
              if current_language == :fr
                if self.french_welcome_text?
                  Setting.plugin_redmine_clf2['welcome_text_fr']
                elsif self.english_welcome_text?
                  english_welcome_text
                else
                  ''
                end
              else
                if self.english_welcome_text?
                  english_welcome_text
                elsif self.french_welcome_text?
                  Setting.plugin_redmine_clf2['welcome_text_fr']
                else
                  ''
                end

              end
            end
          end
        end
      end

      module ClassMethods
        def english_welcome_text?
          self[:welcome_text].present?
        end

        def french_welcome_text?
          Setting.plugin_redmine_clf2 && Setting.plugin_redmine_clf2['welcome_text_fr'].present?
        end

        def current_language_welcome_text_present?
          (current_language == :fr && french_welcome_text?) || (current_language == :en && english_welcome_text?)
        end
      end
    end
  end
end
