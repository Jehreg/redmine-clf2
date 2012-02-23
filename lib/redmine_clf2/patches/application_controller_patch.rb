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
          helper_method :change_locale_link
          alias_method_chain :set_localization, :clf_mods
          alias_method_chain :logged_user=, :clf_mods
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

      def change_locale_link(locale)
        request.path + "?#{request.query_string}&lang=#{locale}"
      end

      def set_localization_with_clf_mods
        lang = nil
        if params[:lang].present?
          lang = session[:lang] = params[:lang]
        elsif session[:lang].present?
          lang = session[:lang]
        elsif User.current.logged?
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

      # Override this method to ensure that session[:language] is preserved on login/logout
      def logged_user_with_clf_mods=(user)
        lang = session[:lang]
        reset_session
        session[:lang] = lang

        if user && user.is_a?(User)
          User.current = user
          session[:user_id] = user.id
        else
          User.current = User.anonymous
        end
      end
    end # InstanceMethods
  end
end

