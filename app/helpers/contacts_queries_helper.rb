# encoding: utf-8
module ContactsQueriesHelper

  def contacts_filters_options_for_select(query)
    options_for_select(contacts_filters_options(query))
  end

  def contacts_filters_options(query)
    options = [[]]
    options += query.available_filters.sort {|a,b| a[1][:order] <=> b[1][:order]}.map do |field, field_options|
      [field_options[:name], field]
    end
  end

  def contacts_column_header(column)
    column.sortable ? sort_header_tag(column.name.to_s, :caption => column.caption,
                                                        :default_order => column.default_order) :
                      content_tag('th', h(column.caption))
  end

  def contacts_column_content(column, contact)
    value = column.value(contact)
    case value.class.name
    when 'String'
      if column.name == :subject
        link_to(h(value), :controller => 'contacts', :action => 'show', :id => contact)
      elsif  column.name == :name || column.name == :contacts
        contact_tag(contact)
      elsif  column.name == :email
        contact.primary_email
      elsif  column.name == :phone
        contact.phones.first
      else
        h(value)
      end
    when 'Time'
      format_time(value)
    when 'Date'
      format_date(value)
    when 'Fixnum', 'Float'
      if column.name == :done_ratio
        progress_bar(value, :width => '80px')
      else
        h(value.to_s)
      end
    when 'User'
      link_to_user value
    when 'Project'
      link_to_project value
    when 'Version'
      link_to(h(value), :controller => 'versions', :action => 'show', :id => value)
    when 'TrueClass'
      l(:general_text_Yes)
    when 'FalseClass'
      l(:general_text_No)
    when 'Contact'
      link_to_contact(value, :subject => false)
    else
      h(value)
    end
  end

  # Retrieve query from session or build a new query
  def retrieve_contacts_query
    if !params[:query_id].blank?
      cond = "project_id IS NULL"
      cond << " OR project_id = #{@project.id}" if @project
      @query = ContactsQuery.find(params[:query_id], :conditions => cond)
      raise ::Unauthorized unless @query.visible?
      @query.project = @project
      session[:contacts_query] = {:id => @query.id, :project_id => @query.project_id}
      sort_clear
    elsif api_request? || params[:set_filter] || session[:contacts_query].nil? || session[:contacts_query][:project_id] != (@project ? @project.id : nil)
      # Give it a name, required to be valid
      @query = ContactsQuery.new(:name => "_")
      @query.project = @project
      @query.build_from_params(params)
      session[:contacts_query] = {:project_id => @query.project_id, :filters => @query.filters, :group_by => @query.group_by, :column_names => @query.column_names}
    else
      # retrieve from session
      @query = ContactsQuery.find_by_id(session[:contacts_query][:id]) if session[:contacts_query][:id]
      @query ||= ContactsQuery.new(:name => "_", :filters => session[:contacts_query][:filters], :group_by => session[:contacts_query][:group_by], :column_names => session[:contacts_query][:column_names])
      @query.project = @project
    end
  end


end
