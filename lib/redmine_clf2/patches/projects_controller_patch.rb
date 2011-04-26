# Patches to the ProjectsController
module RedmineClf2
  module Patches 
    module ProjectsControllerPatch
      def self.included(base)
        base.class_eval do
          helper :admin
        end
      end
    end
  end
end
