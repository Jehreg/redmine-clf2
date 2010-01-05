# Patched to the ApplicationController
module Clf2
  module ApplicationController
    module Patch
      def self.included(base)
        base.extend(::Clf2::ApplicationController::ClassMethods)
        base.class_eval do
          cattr_accessor :clf2_subdomain_languages

          base.send(:include, ::Clf2::ApplicationController::InstanceMethods)

          # Skip Redmine's default :set_localization
          skip_before_filter :set_localization
          # Add our :set_localization method to the start of the chain
          prepend_before_filter_if_not_already_added :set_localization
          # Add set_localization_from_domain to the very beginning
          prepend_before_filter_if_not_already_added :switch_language_from_domain

          alias_method_chain :set_localization, :clf_mods  

          base.load_clf2_subdomains_file
          
          helper :clf2
        end
      end
    end

    module ClassMethods
      # Wraps +prepend_before_filter+ in a test to make sure a filter
      # isn't being added multiple times, which can happen with class
      # reloading in development mode
      def prepend_before_filter_if_not_already_added(method)
        unless filter_already_added? method
          prepend_before_filter method
        end
      end

      # Wraps +before_filter+ in a test to make sure a filter
      # isn't being added multiple times, which can happen with class
      # reloading in development mode
      def before_filter_if_not_already_added(method)
        unless filter_already_added? method
          before_filter method
        end
      end
      
      # Checks if a filter has already been added to the filter_chain
      def filter_already_added?(filter)
        return self.filter_chain.collect(&:method).include?(filter)
      end

      # Load the clf2_subdomains.yml file to configure the subdomain
      # to language mapping.  In development mode this will be
      # reloaded with each request but in production, it will be cached.
      def load_clf2_subdomains_file
        domain_file = File.join(Rails.plugins['redmine_clf2'].directory,'config','clf2_subdomains.yml')
        if File.exists?(domain_file)
          self.clf2_subdomain_languages = YAML::load(File.read(domain_file))
          logger.debug "Loaded CLF2 subdomain file"
        else
          logger.error "CLF2 subdomain file not found at #{domain_file}. Subdomain specific languages will not be used."
        end
      end
    end
    
    # Additional InstanceMethods
    module InstanceMethods
      def switch_language_to(language)
        # Guard against a loop since this runs for the
        # LanguageSwitcherController also
        unless params[:controller] == 'language_switcher'
          redirect_to :controller => 'language_switcher', :action => language
        end
      end

      def switch_language_from_domain
        # Skip if language is already set
        return true if session[:language]

        subdomain = request.subdomains.first

        if subdomain && self.clf2_subdomain_languages.respond_to?(:key?) && self.clf2_subdomain_languages.key?(subdomain)
          logger.info ">>> Switching language from domain"

          if self.clf2_subdomain_languages[subdomain] == :fr
            switch_language_to(:french)
          elsif self.clf2_subdomain_languages[subdomain] == :en
            switch_language_to(:english)
          else
            # Fallback to the other detection methods
          end
        end
      end

      def set_current_language_from_session
        if session[:language]
          User.current.language = session[:language]
          current_language = session[:language]
        else
          User.current.language = nil unless User.current.logged?
        end
      end

      def set_localization_with_clf_mods
        logger.info ">>> In new set_localization"
        switch_language_to(:french) if request.request_uri =~ /\/french$/ 
        switch_language_to(:english) if request.request_uri =~ /\/english$/
        set_current_language_from_session

        # Most of this is copied from the core, except as noted.
        lang = nil
        if User.current.language.present? # Modified from core
          lang = find_language(User.current.language)
        end
        if lang.nil? && request.env['HTTP_ACCEPT_LANGUAGE']
          accept_lang = parse_qvalues(request.env['HTTP_ACCEPT_LANGUAGE']).first.downcase
          if !accept_lang.blank?
            lang = find_language(accept_lang) || find_language(accept_lang.split('-').first)
          end
        end
        lang ||= Setting.default_language
        set_language_if_valid(lang)

      end
    end # InstanceMethods
  end
end
