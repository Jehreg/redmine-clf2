# Patched to the ApplicationController
module RedmineClf2
  module Patches
    module ApplicationControllerPatch
      def self.included(base)
        base.extend ClassMethods
        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable
          helper :clf2
          cattr_accessor :subdomains, :tld_length
          load_clf2_subdomains_file
          alias_method_chain :set_localization, :clf_mods
          alias_method_chain :logged_user=, :clf_mods
          helper_method :change_locale_link
          self.tld_length = 2
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

      # Load the subdomains.yml file to configure the subdomain
      # to language mapping.  In development mode this will be
      # reloaded with each request but in production, it will be cached.
      def load_clf2_subdomains_file
        subdomains_file = File.join(Rails.plugins['redmine_clf2'].directory,'config','subdomains.yml')
        if File.exists?(subdomains_file)
          self.subdomains = YAML::load(File.read(subdomains_file))
        else
          logger.error "CLF2 subdomain file not found at #{domain_file}. Subdomain specific languages will not be used."
        end
      end
    end
    
    # Additional InstanceMethods
    module InstanceMethods
      def contact
        url = '/projects/ircan-initiative/wiki/Frequently_Asked_Questions'
        head :moved_permanently, :location => url 
      end

      def help
        url = '/projects/help-aide'
        head :moved_permanently, :location => url 
      end

      # Override this method to determine the locale from the URL
      def set_localization_with_clf_mods
        begin
          ActionController::Base.session_options[:domain] = request.domain(self.tld_length)
        rescue
          ActionController::Base.session_options = {:domain => request.domain(self.tld_length)}
        end

        if params[:lang]
          session[:language] = params[:lang]
        end

        if request.get? && canonical_url != request.url
          head :moved_permanently, :location => canonical_url 
        end

        set_language_if_valid(locale_from_url) 
      end

      # Override this method to ensure that session[:language] is preserved on login/logout
      def logged_user_with_clf_mods=(user)
        reset_session if session.respond_to?(:destroy)
        if user && user.is_a?(User)
          User.current = user
          session[:user_id] = user.id
        else
          User.current = User.anonymous
        end
        session[:language] = locale_from_url
      end

      def canonical_url(locale = nil)
        locale ||= locale_from_url

        # Find the canonical subdomains for the current locale
        # as defined in config/subdomains.yml
        canonical_subdomains = self.subdomains.keys.include?(locale) ? 
          self.subdomains[locale].first.split(".") : 
          self.subdomains.values.flatten.first.split(".")

        difference = request.subdomains(self.tld_length).size - canonical_subdomains.size
        number_of_additional_subdomains = [difference, 0].max

        # Preserve additional subdomains if they exist
        additional_subdomains = request.subdomains(self.tld_length).take(number_of_additional_subdomains)
        canonical_subdomains.unshift(additional_subdomains) if additional_subdomains.any?

        # Strip the lang parameter out of the query string if 
        # it's been provided, but leave the other parameters
        query_string = request.query_string.sub(/&lang(\=[^&]*)?(?=&|$)|^lang(\=[^&]*)?(&|$)/, '')
        url = request.url.sub(/\?.*/, '')
        url += "?#{query_string}" unless query_string.empty?

        return url if request.domain(self.tld_length).nil?

        current_domain = request.subdomains(self.tld_length)
        if self.tld_length > 1
          first_domain = request.domain(self.tld_length).split(".").first
          current_domain = current_domain.push(first_domain)
        end

        # Replace the provided subdomains with the canonical ones
        url.sub(current_domain.join("."), canonical_subdomains.join("."))
      end

      def change_locale_link(locale)
        request.path + "?#{request.query_string}&lang=#{locale}"
      end

      private

      def locale_from_url
        # If an explicit lang parameter is provided, it takes precedence over the subdomain
        if params[:lang] && I18n.available_locales.include?(params[:lang].to_sym)
          return params[:lang]
        end

        if request.domain(self.tld_length).nil?
          locales = self.subdomains.keys
        else
          # Find the first locale in config/subdomains.yml 
          # that has a subdomain matching the requested one
          locales = self.subdomains.keys.select{|locale| 
            self.subdomains[locale].find{|subdomain| 
              subdomain.split(".").last == request.domain(self.tld_length).split(".").first
            }
          }
        end

        if locales.length > 1 && session[:language]
          session[:language]
        else
          locales.first
        end
      end
    end # InstanceMethods
  end
end

