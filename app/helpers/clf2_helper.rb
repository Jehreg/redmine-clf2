module Clf2Helper
  # Wraps the render_menu in the Redmine core but will apply CLF
  # specific CSS to the items including the outer menu and inner menu
  def render_clf_menu(menu, project=nil, options = {})
    # Default options
    options = {
      :ul_class => 'nav',
      :li_class => 'menucontent',
      :menulink_class => 'menulink',
      :title => :clf2_text_top_menu
    }.merge(options)

    # Menu links
    links = []
    menu_items_for(menu, project) do |menu_node|
      caption, url, selected = extract_node_details(menu_node, project)

      links << content_tag('li', 
                           link_to(h(caption),
                                   url,
                                   menu_node.html_options(:selected => selected).merge(:class => options[:menulink_class])),
                           :class => options[:li_class])
    end
    if links.empty?
      return nil
    else
      inner_menu = content_tag('ul',
                               links.join("\n"),
                               :class => options[:ul_class])

      return outer_clf_menu(inner_menu, options[:title], options)
    end
  end

  # Renders the outer CLF menu for inner_html and a title.
  def outer_clf_menu(inner_html, title, options = {})
    # Default options
    options = {
      :ul_class => 'nav',
      :title => :clf2_text_top_menu
    }.merge(options)

    content_tag(:ul,
                content_tag(:li,
                            content_tag(:h2,
                                        l(title),
                                        :class => options[:ul_class]) +
                            inner_html),
                :class => options[:ul_class])
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
