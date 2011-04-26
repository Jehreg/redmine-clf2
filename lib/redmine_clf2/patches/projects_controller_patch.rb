# Patches to the ProjectsController
module RedmineClf2
  module Patches 
    module ProjectsControllerPatch
      def self.included(base)
        base.extend(::Clf2::ProjectsController::ClassMethods)
        base.class_eval do
          helper :admin
        end
      end
    end

    module ClassMethods
    end
    
    module InstanceMethods
    end
  end
end
