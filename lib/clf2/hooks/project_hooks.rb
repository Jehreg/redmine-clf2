module Clf2
  module Hooks
    class ProjectHooks < Redmine::Hook::ViewListener
      # :project
      # :form
      def view_projects_form(context={})
        returning '' do |response|
          response << content_tag(:p,
                                  context[:form].text_field(:name_fr) +
                                  '<br />' +
                                  content_tag(:em, l(:text_caracters_maximum, Project::MAXIMUM_CHARACTERS_FOR_NAME)))
          
          response << content_tag(:p, context[:form].text_area(:description_fr, :rows => 5, :class => 'wiki-edit'))
          response << javascript_tag("var wikiToolbar = new jsToolBar($('project_description_fr')); wikiToolbar.draw();")

        end
        
      end
    end
  end
end
