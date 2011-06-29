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
        if session[:language]
          @news = News.latest User.current
          @projects = Project.latest User.current
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
