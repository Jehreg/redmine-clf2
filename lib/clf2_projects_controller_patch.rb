# Patches to the ProjectsController
module Clf2
  module ProjectsController
    module Patch
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
