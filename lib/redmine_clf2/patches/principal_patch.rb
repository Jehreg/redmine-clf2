# Patches for the Principal class (Users and Groups)
module RedmineClf2
  module Patches
    module PrincipalPatch 
      def self.included(base)
        base.class_eval do
          # Patch and override the named_scope.  Should be included in
          # the Redmine core soon
          named_scope :like, lambda {|q| 
            s = "%#{q.to_s.strip.downcase}%"
            {:conditions => ["LOWER(login) LIKE ? OR LOWER(firstname) LIKE ? OR LOWER(lastname) LIKE ? OR LOWER(mail) LIKE ?", s, s, s, s],
              :order => 'type, login, lastname, firstname'
            }
          }
        end
      end
    end
  end
end
