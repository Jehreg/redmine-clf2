# Patched to the ApplicationController
module RedmineClf2
  module Patches
    module ApplicationControllerPatch
      def self.included(base)
        base.extend ClassMethods
        base.send(:include, InstanceMethods)

        base.class_eval do
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
      def rewrite_url
        url = use_canonical_domain(request.url)
        url = strip_lang_parameter(url) 
          
        if request.get? && url != request.url
          head :moved_permanently, :location => url 
        end

        User.current.language = session[:language]
      end

      def strip_lang_parameter(url)
        return url unless params[:lang]

        if I18n.available_locales.include?(params[:lang].to_sym)
          session[:language] = params[:lang] 
        end

        query_string = request.query_string.sub(/&lang(\=[^&]*)?(?=&|$)|^lang(\=[^&]*)?(&|$)/, '')

        url = url.sub(request.host, canonical_host(params[:lang].to_sym))
        url = url.sub(/\?.*/, '')
        url = url + "?#{query_string}" unless query_string.empty?
        return url
      end

      def use_canonical_domain(url)
        locale = locale_from_subdomain
        session[:language] = locale unless (params[:action] == 'index' && session[:user_id].nil?)
        url.sub(request.host, canonical_host(locale))
      end

      def canonical_host(locale)
        @canonical_subdomains = {
          :en => ['tbs-sct', 'ircan-rican'],
          :fr => ['sct-tbs', 'rican-ircan']
        }

        cd = @canonical_subdomains[locale]
        cd = @canonical_subdomains.values.first if cd.nil?
        subdomains = request.subdomains
        subdomains.pop(cd.size)
        (subdomains + cd + request.domain.split(".")).join(".")
      end

      def canonical_url(locale)
        "#{request.protocol}#{canonical_host(locale)}:#{request.port}/"
      end

      def locale_from_subdomain
        @subdomains = [
          ['tbs-sct', 'ircan-rican'],
          ['ircan'],
          ['sct-tbs', 'rican-ircan'],
          ['rican']
        ]

        @locales = {
          'tbs-sct.ircan-rican' => [:en],
          'ircan' => [:en],
          'sct-tbs.rican-ircan' => [:fr],
          'rican' => [:fr]
        }

        subdomain = @subdomains.select{|s| s == request.subdomains.last(s.size)} 
        subdomain = [@subdomains.first] if subdomain.empty?
        
        @locales[subdomain.first.join(".")].first 
      end

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
      end

      def set_current_language_from_session
        if session[:language]
          User.current.language = session[:language]
          current_language = session[:language]
        else
          User.current.language = nil unless User.current.logged?
        end
      end

      def set_localization
        rewrite_url

        lang = session[:language]
        if User.current.logged?
          lang = find_language(User.current.language)
        end
        if lang.nil? && request.env['HTTP_ACCEPT_LANGUAGE']
          accept_lang = parse_qvalues(request.env['HTTP_ACCEPT_LANGUAGE']).first
          if !accept_lang.blank?
            accept_lang = accept_lang.downcase
            lang = find_language(accept_lang) || find_language(accept_lang.split('-').first)
          end
        end
        lang ||= Setting.default_language
        set_language_if_valid(lang)
      end

      def url_for_with_language_in_url(options)
        # Pass without language if options isn't a hash (e.g. url string)
        unless options.respond_to?(:merge)
          return url_for_without_language_in_url(options)
        end
        
        case current_language
        when :en
          url_for_without_language_in_url(options.merge(:lang => 'eng'))
        when :fr
          url_for_without_language_in_url(options.merge(:lang => 'fra'))
        else
          url_for_without_language_in_url(options)
        end
      end
    end # InstanceMethods
  end
end
