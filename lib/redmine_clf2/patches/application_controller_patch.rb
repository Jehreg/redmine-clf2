# Patched to the ApplicationController
module RedmineClf2
  module Patches
    module ApplicationControllerPatch
      def self.included(base)
        base.extend ClassMethods
        base.send(:include, InstanceMethods)

        base.class_eval do
          helper :clf2
          cattr_accessor :locales_subdomains
          load_clf2_subdomains_file
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
        subdomains_file = File.join(Rails.plugins['redmine_clf2'].directory,'config','subdomains.yml')
        if File.exists?(subdomains_file)
          data = YAML::load(File.read(subdomains_file))

          self.locales_subdomains = data
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

      def strip_lang_parameter(url)
        return url unless params[:lang]

        if I18n.available_locales.include?(params[:lang].to_sym)
          session[:language] = params[:lang]
        end

        url = url.sub(request.host, canonical_host(params[:lang].to_sym))
        url = url.sub(/\?.*/, '')

        query_string = request.query_string.sub(/&lang(\=[^&]*)?(?=&|$)|^lang(\=[^&]*)?(&|$)/, '')
        url = url + "?#{query_string}" unless query_string.empty?
        return url
      end

      def canonical_url(locale)
        request.url.sub(request.host, canonical_host(locale))
      end

      def use_canonical_domain(url, locale = nil)
        locale ||= locale_from_subdomain
        url.sub(request.host, canonical_host(locale))
      end

      def canonical_host(locale)
        if self.locales_subdomains.keys.include?(locale.to_s)
          canonical_subdomains = self.locales_subdomains[locale.to_s].first.split(".")
        else
          canonical_subdomains = self.locales_subdomains.values.flatten.first.split(".")
        end

        other_subdomains = request.subdomains.take(request.subdomains.size - canonical_subdomains.size)
        top_level_domains = request.domain.split(".")

        (other_subdomains + canonical_subdomains + top_level_domains).join(".")
      end

      def locale_from_subdomain
        ls = self.locales_subdomains
        d = request.subdomains
        ls.keys.find{|k| ls[k].select{|s| s.split(".") == d.last(s.size)}.any?}
      end

      def set_localization
        url = use_canonical_domain(request.url)
        url = strip_lang_parameter(url) 

        if request.get? && url != request.url
          head :moved_permanently, :location => url 
        end

        params[:lang] ||= locale_from_subdomain
        session[:language] = params[:lang] unless request.path == '/'

        set_language_if_valid(params[:lang].to_s)
      end
    end # InstanceMethods
  end
end
