# Source od grid data comes from Array

module DataGrid
  class DataSourceArray

    attr_accessor :data_grid

    # Main function which prepares data
    def prepare_data
      initial_data_eval 
      initial_sorting if self.data_grid.sorting?
      filter
      global_summary_array
      pagination
      summary_array
      self.data_grid.row_styler
      prepare_data_for_filters
    end
 
    
  private

    def direction_as_int
      if self.data_grid.sort_direction == 'ASC'
        return 1
      else
        return -1
      end
    end

    # Eval lambdas
    def initial_data_eval
      self.data_grid.in_data.each_with_index do |row, row_index|
        entry = []

        self.data_grid.columns.each_with_index do |col, index|
          # Eval if sorting or filtering by or summary column
          if (self.data_grid.sort == index) or (col.filter and !col.filter_value.blank?) or col.global_summary or col.summary
            if col.sort_by.class == Symbol
              if col.sort_by != col.field
                if col.field.class == Symbol
                  to_entry = [row.send(col.field), row.send(col.sort_by)]
                else
                  to_entry = [col.field.call(row, self.data_grid.view_context), row.send(col.sort_by)]
                end
              else
                to_entry = row.send(col.sort_by)
              end
            else
              # Call lambda
              to_entry = col.field.call(row, self.data_grid.view_context)
            end
          else
            # Other column are not evaluated, for now has only row index
            to_entry = row_index
          end

          to_entry = 0 if to_entry.nil?
          entry << to_entry
        end

        self.data_grid.out_data << entry
      end
    end

    # Initial sorting
    def initial_sorting
      self.data_grid.out_data.sort! do |a, b|
        a_v = a[self.data_grid.sort]
        b_v = b[self.data_grid.sort]

        a_v = a_v[1] if a_v.class == Array
        b_v = b_v[1] if b_v.class == Array

        a_v = a_v.upcase if a_v.class == String
        b_v = b_v.upcase if b_v.class == String
        if (a_v > b_v)
          direction_as_int
        else
          if a_v == b_v
            0
          else
            direction_as_int * -1
          end
        end
      end
    end

    # Filter
    def filter
      if self.data_grid.filters?
        date_format = I18n.t(:"date.formats.default", {:locale => I18n.locale })
        filtered_data = []
        self.data_grid.out_data.each do |row|
          add_row = true
          self.data_grid.columns.each_with_index do |col, col_index|
            if col.filter and !col.filter_value.blank?
              case col.filter
              when :auto
                add_row = false if row[col_index] != col.filter_value
              when :text
                add_row = false if row[col_index] !~ Regexp.new(col.filter_value, true) and row[col_index].first !~ Regexp.new(col.filter_value, true) 
              when :number
                add_row = false if row[col_index].to_f != col.filter_value.to_f
              when :range
                range = col.filter_value.split(DataGrid.range_separator)

                if !range[0].blank? and !range[1].blank?
                  begin
                    range[0] < 2
                  rescue
                    range[0] = range[0].to_f
                    range[1] = range[1].to_f
                  end
                  add_row = false if row[col_index] < range[0] or row[col_index] > range[1]
                elsif range[0].blank? and !range[1].blank?
                  begin
                    range[1] < 2
                  rescue
                    range[1] = range[1].to_f
                  end
                  add_row = false if row[col_index] > range[1]
                elsif range[1].blank? and !range[0].blank?
                  begin
                    range[0] < 2
                  rescue
                    range[0] = range[0].to_f
                  end
                  add_row = false if row[col_index] < range[0]
                end

              when :date
                range = col.filter_value.split(DataGrid.range_separator)

                if !range[0].blank? and !range[1].blank?
                  begin
                    range[0] < 2
                  rescue
                    range[0] = DateTime.strptime(range[0], date_format)
                    range[1] = DateTime.strptime(range[1], date_format)
                  end
                  add_row = false if row[col_index].class == Fixnum or row[col_index] < range[0] or row[col_index] > range[1]
                elsif range[0].blank? and !range[1].blank?
                  begin
                    range[1] < 2
                  rescue
                    range[1] = DateTime.strptime(range[1], date_format)
                  end
                  add_row = false if row[col_index].class == Fixnum or row[col_index] > range[1]
                elsif range[1].blank? and !range[0].blank?
                  begin
                    range[0] < 2
                  rescue
                    range[0] = DateTime.strptime(range[0], date_format)
                  end
                  add_row = false if row[col_index].class == Fixnum or row[col_index] < range[0]
                end

              end
            end
          end
          filtered_data << row if add_row
        end

        self.data_grid.out_data = filtered_data
      end
    end
    
    
    # Pagination
    def pagination
      self.data_grid.total = self.data_grid.out_data.size
      self.data_grid.pages = self.data_grid.out_data.size/self.data_grid.per_page
      self.data_grid.pages = (self.data_grid.pages != self.data_grid.pages.ceil) ? self.data_grid.pages.ceil + 1 : self.data_grid.pages.ceil

      page = self.data_grid.page
      per_page = self.data_grid.per_page

      offset = (page - 1) * per_page
      if !paged_out_data = self.data_grid.out_data[offset..(offset + per_page - 1)]
        paged_out_data = self.data_grid.out_data[0..(per_page - 1)]
      end

      self.data_grid.out_data = []
      paged_out_data.each_with_index do |row, row_index|
        entry = []

        self.data_grid.columns.each_with_index { |col, index|
          # If colum is sorted/filtered/summary
          if (self.data_grid.sort != index) and (!col.filter or col.filter_value.blank?) and !col.summary and !col.global_summary
            field = row[index]
            if col.field.class == Symbol
              if col.field == :auto
                entry << row_index + 1 + (page-1)*per_page
              else
                entry << self.data_grid.in_data[field].send(col.field)
              end
            else
              entry << col.field.call(self.data_grid.in_data[field], self.data_grid.view_context)
            end
          else
            entry << row[index]
          end
        }

        self.data_grid.out_data << entry
      end
    end
    
    # Prepare data for filters
    def prepare_data_for_filters
      self.data_grid.columns.each do |col|
        next if col.filter.nil? # if no filter

        # Prepare auto filters
        if col.filter == :auto
          self.data_grid.in_data.each do |d|
            if col.sort_by.class == Symbol
              col.filter_data << d.send(col.sort_by)
            else
              # Call lambda
              col.filter_data << col.field.call(d, self.data_grid)
            end
          end

          col.filter_data.uniq!
          col.filter_data.sort!
        end
      end
    end
    
    # Summary
    def summary_array
      if self.data_grid.summary?
        self.data_grid.summaries = []
        self.data_grid.columns.each_with_index do |col, col_index|
          if col.summary
            column_data = []
            self.data_grid.out_data.each do |row|
              column_data << row[col_index]
            end

            self.data_grid.summaries[col_index] = DataGrid::Summaries.send(col.summary, column_data)
          end
        end
      end
    end

    # Global Summary
    def global_summary_array
      if self.data_grid.summary?
        self.data_grid.global_summaries = []
        self.data_grid.columns.each_with_index do |col, col_index|
          if col.global_summary
            column_data = []
            self.data_grid.out_data.each do |row|
              column_data << row[col_index]
            end

            self.data_grid.global_summaries[col_index] = DataGrid::Summaries.send(col.global_summary, column_data)
          end
        end
      end
    end
  end
end

