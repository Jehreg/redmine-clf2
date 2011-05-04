module Clf2Helper
  # Wraps the render_menu in the Redmine core but will apply CLF
  # specific CSS to the items including the outer menu and inner menu
  def render_clf_menu(menu, project=nil, options = {})
    # Default options
    options = {
      :title => :clf2_text_top_menu
    }.merge(options)

    # Menu links
    links = []
    menu_items_for(menu, project) do |menu_node|
      caption, url, selected = extract_node_details(menu_node, project)

      links << content_tag('li', link_to(
        h(caption),
        url,
        menu_node.html_options(:selected => selected)))
    end
    if links.empty?
      return nil
    else
      return content_tag(:h3, l(options[:title])) + content_tag(:ul, content_tag(:li, links.join("\n")))
    end
  end

  # Wraps the Redmine core's render_main_main but using the CLF
  # helpers to generate the correct CLF structure and classes
  def render_clf_main_menu(project, options = {})
    # Default options
    options = {
      :ul_class => 'nav',
      :li_class => 'menucontent',
      :menulink_class => 'menulink',
      :title => :clf2_text_main_menu
    }.merge(options)

    render_clf_menu((project && !project.new_record?) ? :project_menu : :application_menu, project, options)
  end

  # Truncate text based on word boundries
  def truncate_words(text, length = 30, end_string = ' ...')
    return if text == nil
    words = text.split
    words[0..(length-1)].join(' ') + (words.length > length ? end_string : '')
  end

  def breadcrumbs 
    if @project.nil? || @project.new_record?
      concat('<li>&nbsp;</li>')
    else
      projects = @project.root? ? [@project] : (@project.ancestors.visible.all + [@project])
      projects.each_with_index do |p,i|
        separator = i == (projects.length - 1) ? '' : '&#160;&#62;'
        concat("<li>#{link_to_project(p, {:jump => current_menu_item}, :rel => ("up" *  (projects.length - i))) }#{separator}</li>")
      end
    end
  end

  def project_tree_options_for_select(projects, options = {})
    s = ''
    projects.each do |project|
      tag_options = {:value => project.id}
      if project == options[:selected] || (options[:selected].respond_to?(:include?) && options[:selected].include?(project))
        tag_options[:selected] = 'selected'
      else
        tag_options[:selected] = nil
      end
      tag_options.merge!(yield(project)) if block_given?
      s << content_tag('option', h(project), tag_options)
    end
    s
  end
end
