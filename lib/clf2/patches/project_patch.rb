# Patches for the Project class
module Clf2
  module Patches
    module ProjectPatch
      def self.included(base)
        base.send(:include, InstanceMethods)
      end

      module InstanceMethods
        # Wrap the description field so it will serve up the French or
        # English version based on the current language.  If the main
        # one that is requested isn't present, the alternative will be returned
        def description
          case
          when current_language == :fr && french_description?
            read_attribute(:description_fr)

          when current_language == :fr && english_description?
            read_attribute(:description)

          when current_language != :fr && english_description?
            read_attribute(:description)

          when current_language != :fr && french_description?
            read_attribute(:description_fr)

          else
            ''
          end
        end

        # Wrap the Project name field so it will serve up the French
        # or English version based on the current language.
        def name
          case
          when current_language == :fr && french_name?
            read_attribute(:name_fr)

          when current_language == :fr && english_name?
            read_attribute(:name)

          when current_language != :fr && english_name?
            read_attribute(:name)

          when current_language != :fr && french_name?
            read_attribute(:name_fr)

          else
            ''
          end
        end

        def english_description?
          read_attribute(:description).present?
        end

        def french_description?
          read_attribute(:description_fr).present?
        end

        # Will always be true because name is required
        def english_name?
          read_attribute(:name).present?
        end

        def french_name?
          read_attribute(:name_fr).present?
        end

        def current_language_description_present?
          (current_language == :fr && french_description?) || (current_language == :en && english_description?)
        end

        def current_language_name_present?
          (current_language == :fr && french_name?) || (current_language == :en && english_name?)
        end
      end
    end
  end
end
