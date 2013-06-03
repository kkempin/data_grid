# Module used to export data to CSV

class CsvContent 
  include ActionView::Helpers::TagHelper 
  include ActionView::Helpers::FormTagHelper

  def image_tag name, options = nil
    ''
  end

  def link_to name, options=nil, extra=nil
    name
  end

  def raw s=''
    s.to_s.gsub('<br />', ', ')
  end
end


module DataGrid
  module Controller
    # Do CSV export
     def export(data_grid, filename = DataGrid.export_filename)
      require 'csv'
      
      if request.env['HTTP_USER_AGENT'] =~ /msie/i
       headers['Pragma'] = 'public'
       headers["Content-type"] = "text/plain; charset=utf-8; header=present"
       headers['Cache-Control'] = 'no-cache, must-revalidate, post-check=0, pre-check=0'       
       headers['Content-Disposition'] = "attachment; filename=\"#{filename}\""
       headers['Expires'] = "0" 
      else
        headers["Content-Type"] ||= 'text/csv; charset=utf-8; header=present'   
        headers["Content-Disposition"] = "attachment; filename=\"#{filename}\""
      end  
      data_grid.view_context = CsvContent.new
      data_grid.prepare_data

      csv_string = CSV.generate(:col_sep => ';') do |csv|
        hide_column_indexes = []
        cols = []
        data_grid.columns.each_with_index do |col, i|
          if col.hide_in_export 
            hide_column_indexes << i
          else
            cols << col.title
          end
        end
        csv << cols
        data_grid.out_data.each_with_index do |row, row_index|
          data_row = []
          row.each_with_index do |row_col, i|
            next if (!data_grid.hidden_row.nil? and i == row.size-1)
            unless hide_column_indexes.include?(i)
              data_row << ((row_col.class == ActiveSupport::SafeBuffer) ? row_col.to_s.gsub(/<\/?[^>]*>/, "") : (row_col.class == String) ? row_col.gsub(/<\/?[^>]*>/, "") : row_col)
            end
          end
          unless data_grid.hidden_row.nil?
            data_row << data_grid.out_hidden_rows[row_index] 
          end
          csv << data_row
        end

        if data_grid.summary? 
          data_row = []
			    data_grid.columns.each_with_index {|col, i| 
          	data_row <<  data_grid.summaries[i].to_s unless hide_column_indexes.include?(i)
          } 
          csv << data_row
			  end 

      end

      render :text => csv_string
    end
  end
end

