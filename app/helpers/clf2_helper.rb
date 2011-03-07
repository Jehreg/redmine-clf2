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
end
