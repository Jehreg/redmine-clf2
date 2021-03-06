module RedmineClf2
  module Patches
    module WelcomeControllerPatch
      def self.included(base)
        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable
          alias_method_chain :index, :clf_mods
        end
      end
    end

    module InstanceMethods
      def index_with_clf_mods
        if session[:lang].present?
          @news = News.latest(User.current).select{|n| n.project.to_s == 'IRCan Franchise of TBS'}
        else
          render :action => 'welcome', :layout => 'wp-pa' 
        end
      end

      def welcome
        render :layout => 'wp-pa' 
      end
    end 
  end
end
