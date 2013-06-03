# encoding: utf-8
# Views methods

module DataGrid
  module ViewHelpers

    # FORMATERS
    def data_grid_formatter_plain_text(txt)
      txt
    end
  
    def data_grid_formatter_bold(txt)
      raw "<strong>#{txt}</strong>"
    end
  
    def data_grid_formatter_money_pl(price)
      pieces = price.to_s.split('<br />')
      results = []
      pieces.each do |p|
        p = p.to_f
        p = ((p*100.0).round)/100.0
        result = p.to_s
        result = result + '0' if (((p*10).to_s == (p*10).to_i.to_f.to_s) and (p > 0))
        result = '0' if p.zero?

        results << result.gsub('.', ',')
      end
      raw(results.join('<br />'))
    end
  
    def data_grid_formatter_datetime(dt)
      I18n.l(dt)
    end
  
    def data_grid_formatter_date(d)
      I18n.l(d)
    end

    def show_grid(data_grid)
      data_grid.view_context = self
      data_grid.prepare_data
      render 'data_grid/data_grid', :data_grid => data_grid
    end

    # Simple slug method used in URL params - column names
    def slug(p_str)
      str = String.new(p_str)
      str.strip!

      s =  ['ą', 'ć', 'ę', 'ł', 'ń', 'ó', 'ś', 'ż', 'ź',
                   'Ą', 'Ć', 'Ę', 'Ł', 'Ń', 'Ó', 'Ś', 'Ż', 'Ź',
                   'é', 'à', ' - ', 'À', 'Á', 'Ã', 'Ä', 'Å',
                   'Æ', 'Ç', 'È', 'É', 'Ê', 'Ë', 'Ì', 'Í', 'Î',
                   'Ï', 'Đ', 'Ñ', 'Ô', 'Õ', 'Ö', 'Ù', 'Û', 'Ý',
                   'ß', 'à', 'á', 'â', 'ã', 'ä', 'å', 'æ', 'ç',
                   'è', 'é', 'ê', 'ë', 'ì', 'í', 'í', 'î', 'ï',
                   'ñ', 'ò', 'ô', 'õ', 'ö', 'ù', 'ú', 'û', 'ü',
                   'ý', 'ÿ', '€', '$', 'Š', 'š', 'ž', 'Œ', 'œ',
                   'Ÿ', '§', '@' ]
      r = ['a', 'c', 'e', 'l', 'n', 'o', 's', 'z', 'z',
                   'a', 'c', 'e', 'l', 'n', 'o', 's', 'z', 'z',
                   'e', 'a', '-', 'a', 'a', 'a', 'a', 'a',
                   'ae', 'c', 'e', 'e', 'e', 'e', 'i', 'i', 'i',
                   'i', 'd', 'n', 'o', 'o', 'o', 'u', 'u', 'y',
                   'b', 'a', 'a', 'a', 'a', 'a', 'a', 'ae', 'c',
                   'e', 'e', 'e', 'e', 'i', 'i', 'i', 'i', 'i',
                   'n', 'o', 'o', 'o', 'o', 'u', 'u', 'u', 'u',
                   'y', 'y', 'e', 's', 's', 's', 'z', 'oe', 'oe',
                   'y', 'p', 'at' ]
      s.each_index {|i| str.gsub!(s[i], r[i])}
      str.downcase!
      str.gsub!(Regexp.new('\ +'), '-')
      str.gsub!(Regexp.new('[^A-z0-9\-]'), '')
      str.gsub!(Regexp.new('\-+', '-'), '-')
      str
    end

    # Render given column header
    def data_grid_header(data_grid, column)
      if column.sortable
        col_index = data_grid.columns.index(column)
        link_to(raw(column.title), data_grid.params.merge(
          "sort_#{data_grid.name}" => slug(column.title) + '_' + col_index.to_s,
          "sort_direction_#{data_grid.name}" => ((data_grid.sort == col_index) and (data_grid.sort_direction == 'ASC')) ? 'DESC' : 'ASC'), :class => 'underline sorting ' + ((data_grid.sort == col_index) ? ((data_grid.sort_direction == 'ASC') ? 'up' : 'down') : '')) 
      else
        raw column.title
      end
    end
  
    # Show export link
    def data_grid_export_link(data_grid)
      link_to(
        image_tag("data_grid/#{data_grid.export_enabled}.gif", :border => 0), 
        data_grid.params.merge("export_#{data_grid.name}" => data_grid.export_enabled)
      )
    end

    # Based on column filter type, display form with inputs
    def data_grid_filter(data_grid, column)
      hidden_submit_input = '<input type="submit" value="" style="width:0px; height: 0px; border: none; padding: 0px; font-size: 0px">'.html_safe
      output = ''
      col_index = data_grid.columns.index(column)
      case column.filter
      when :boolean
        filter_select_name = "filter_#{data_grid.name}_#{col_index}"
        base_url = url_for(data_grid.params.merge(filter_select_name => nil))
        output = select_tag(filter_select_name,
          options_for_select([[I18n.t('data_grid.all_options'), ''], [I18n.t('data_grid.option_true'), '1'], [I18n.t('data_grid.option_false'), '0']], column.filter_value),
          :onchange => "window.location.href='#{base_url}#{(base_url.include?('?')) ? '&' : '?' }#{filter_select_name}=' + this.value")
      when :auto
        filter_select_name = "filter_#{data_grid.name}_#{col_index}"
        base_url = url_for(data_grid.params.merge(filter_select_name => nil))
        output = select_tag(filter_select_name,
          options_for_select([[I18n.t('data_grid.all_options'), '']] + column.filter_data.map{|fd| [column.auto_filter_hash.nil? ? fd : column.auto_filter_hash[fd.to_s.to_sym], fd]}, column.filter_value),
          :onchange => "window.location.href='#{base_url}#{(base_url.include?('?')) ? '&' : '?' }#{filter_select_name}=' + this.value")
      
      when :text
        filter_input_name = "filter_#{data_grid.name}_#{col_index}"
        base_url = url_for(data_grid.params.merge(filter_input_name => nil))
        output = form_tag(base_url, :method => 'GET') do
          text_field_tag(filter_input_name, column.filter_value) + 
          data_grid_dump_as_hidden_fields(data_grid, [filter_input_name]) + 
          hidden_submit_input
        end
      when :number
        filter_input_name = "filter_#{data_grid.name}_#{col_index}"
        base_url = url_for(data_grid.params.merge(filter_input_name => nil))
        output = form_tag(base_url, :method => 'GET') do
          text_field_tag(filter_input_name, column.filter_value, :class => 'data_grid_filter_input') + 
          data_grid_dump_as_hidden_fields(data_grid, [filter_input_name]) + 
          hidden_submit_input
        end
      when :range
        filter_input_name_from = "filter_#{data_grid.name}_#{col_index}_from"
        filter_input_name_to = "filter_#{data_grid.name}_#{col_index}_to"
        base_url = url_for(data_grid.params.merge(filter_input_name_from => nil, filter_input_name_to => nil))
        output = form_tag(base_url, :method => 'GET') do
          data_grid_dump_as_hidden_fields(data_grid, [filter_input_name_from, filter_input_name_to]) + 
          text_field_tag(filter_input_name_from, column.filter_value.to_s.split(DataGrid.range_separator)[0], :class => 'data_grid_filter_input') + 
          ' - ' + 
          text_field_tag(filter_input_name_to, column.filter_value.to_s.split(DataGrid.range_separator)[1], :class => 'data_grid_filter_input') +
          hidden_submit_input
        end
      
      when :date        
        date_format = I18n.t(:"date.formats.default", {:locale => I18n.locale })
        filter_input_name_from = "filter_#{data_grid.name}_#{col_index}_from"
        filter_input_name_to = "filter_#{data_grid.name}_#{col_index}_to"
        form_id = "filter_#{data_grid.name}_#{col_index}_form"
      
        base_url = url_for(data_grid.params.merge(filter_input_name_from => nil, filter_input_name_to => nil))
        output = "<form method='get' action='#{base_url}' id='#{form_id}'>"
        output << data_grid_dump_as_hidden_fields(data_grid, [filter_input_name_from, filter_input_name_to])
      
        date_picker, datepicker_placeholder_id, trigger_id, dom_id, date_span_id = select_date_datetime_common(
        {:id => "filter_#{data_grid.name}_#{col_index}_from", :name => filter_input_name_from}, data_grid.params[filter_input_name_from], form_id)

        output << "#{I18n.t('data_grid.filter_date_from')}: <span id=\"#{datepicker_placeholder_id}\">#{date_picker}</span>"
        output << %(<script type="text/javascript">\n)
        output << %(    Calendar.setup\({\n)
        output << %(        button : "#{trigger_id}",\n )
        output << %(        ifFormat : "#{date_format}",\n )
        output << %(        inputField : "#{dom_id}",\n )
        output << %(        include_blank : true,\n )
        output << %(        singleClick    :    true,\n)
        output << %(        onClose    :    function(cal){handleCalendarClose(cal, "#{dom_id}", "#{form_id}");}\n)
        output << %(    }\);\n)
        output << %(</script><br />\n)
      
        date_picker, datepicker_placeholder_id, trigger_id, dom_id, date_span_id = select_date_datetime_common(
        {:id => "filter_#{data_grid.name}_#{col_index}_to", :name => filter_input_name_to}, data_grid.params[filter_input_name_to], form_id)

        output << "#{I18n.t('data_grid.filter_date_to')}: <span id=\"#{datepicker_placeholder_id}\">#{date_picker}</span>"
        output << %(<script type="text/javascript">\n)
        output << %(    Calendar.setup\({\n)
        output << %(        button : "#{trigger_id}",\n )
        output << %(        ifFormat : "#{date_format}",\n )
        output << %(        inputField : "#{dom_id}",\n )
        output << %(        include_blank : true,\n )
        output << %(        singleClick    :    true,\n)
        output << %(        onClose    :    function(cal){handleCalendarClose(cal, "#{dom_id}", "#{form_id}");}\n)
        output << %(    }\);\n)
        output << %(</script>\n)
      
        output << hidden_submit_input
        output << '</form>'
      
      else
        output = '&nbsp;'
      end

      raw output
    end
  
    # Prepare calendar in filters area
    def select_date_datetime_common(options, date_string, form_id)  #:nodoc:
      dom_id = options[:id]
    
      trigger_id = dom_id + '_trigger'
      datepicker_placeholder_id = dom_id + '_date_placeholder'
      date_span_id = dom_id + '_date_view'

      date_picker = image_tag('data_grid/calendar_view_month.png', :id => trigger_id, :style => 'cursor: pointer') +

      link_to_function(
        content_tag(:span, date_string, :id => date_span_id),
        %! dataGridSetInnerHtml("#{date_span_id}", ""); dataGridSetValue("#{dom_id}", ""); handleCalendarClose(false, "#{dom_id}", "#{form_id}");!,
        :class => 'date_label') + ' ' +

        hidden_field_tag(options[:name], date_string, :class => 'text-input', :id => dom_id,
          :onchange => "dataGridSetInnerHtml(\"#{date_span_id}\", this.value);")

      return date_picker, datepicker_placeholder_id, trigger_id, dom_id, date_span_id
    end


    # Display data_grid per page selector
    def data_grid_per_page_selector(data_grid)
      per_page_param = "per_page_#{data_grid.name}"
      base_url = url_for(data_grid.params.merge(per_page_param => nil))
      select_tag(:per_page,
        options_for_select(DataGrid.available_per_pages, data_grid.per_page),
        :onchange => "window.location.href='#{base_url}#{(base_url.include?('?')) ? '&' : '?' }#{per_page_param}=' + this.value", :class => 'data_grid_per_page_selector')
    end


    # Dump all data_grid options as hidden fields
    def data_grid_dump_as_hidden_fields(data_grid, except = [])
      output = ''
      data_grid.params.each_pair do |k, v|
        next if except.include?(k)
        output << hidden_field_tag(k, v)
      end
      output.html_safe
    end
  

    # Displays data grid pager
    def data_grid_pager(data_grid)
      output = []
      if data_grid.pages < 8
        1.upto(data_grid.pages){|page_number|
          if data_grid.page == page_number or data_grid.page == 0
            output << "<li>#{page_number}</li>"
          else
            output << '<li>' + link_to(page_number, data_grid.params.merge('page_' + data_grid.name => page_number) ) + '</li>'
          end
        }
      else
        if data_grid.page - 4 > 0
          output << '<li>' + link_to("1", data_grid.params.merge('page_' + data_grid.name => 1), :class => 'prev' ) + '</li><li>...</li>'
        end
        1.upto(data_grid.pages){|page_number|
          if data_grid.page == page_number or data_grid.page == 0
            output << "<li>#{page_number}</li>"
          else
            if page_number > data_grid.page - 4 and page_number < data_grid.page + 4
              output << '<li>' + link_to(page_number, data_grid.params.merge('page_' + data_grid.name => page_number) ) + '</li>'
            end
          end
        }
        if data_grid.page + 3 < data_grid.pages
          output << '<li>...</li><li>' + link_to("#{data_grid.pages}",data_grid.params.merge('page_' + data_grid.name => data_grid.pages), :class => 'next' ) + '</li>'
        end
      end
    
      raw("<ul class='data_grid_pagination'>" + output.join(' ') + "</ul>")
    end
  end
end

