module DataGrid
  class DataGridLogic

    attr_accessor :per_page, :page, :name, :columns, :in_data, :out_data, :data_class, :params, :sort, :sort_direction, :view_context, :pages, :total, :export_enabled, :summaries, :row_styles, :state_saver, :show_footer, :hidden_row, :out_hidden_rows, :initial_sort, :global_summaries, :count_statement, :extra_orm_options, :export_filename
    

    # Initialize
    def initialize(attrs = {})
      # Internal copy od request params
      self.params = attrs[:params].except(:action).except(:controller).except(:utf8)

      # Display rows per page
      self.per_page = (attrs[:per_page] || DataGrid.per_page).to_i

      # Current page
      self.page = (attrs[:page] || 1).to_i 
      self.page = 1 if self.page <= 0
      self.page = 1 if self.page >= 10000000

      # DataGrid name. Has to be set if two or more grids on page.
      self.name = attrs[:name] || ''

      # Sort by this field
      self.sort = attrs[:sort]

      # Sort direction - (asc, desc)
      self.sort_direction = attrs[:sort] || DataGrid.sort_direction

      # Internal array of columns
      self.columns = attrs[:columns] || []

      # Internal representation of prepared data to display
      self.out_data = []

      # Name of state saver method - (cookies)
      self.state_saver = attrs[:state_saver]

      # Show grid footer?
      self.show_footer = attrs[:show_footer] || DataGrid.show_footer

      # Internal representation of hidden rows - row below each row
      self.hidden_row = attrs[:hidden_row]

      # Internal representation of prepared hidden rows
      self.out_hidden_rows = []

      # Initial data grid sorting (ie. 'age ASC')
      self.initial_sort = attrs[:initial_sort]

      # SQL which counts rows 
      self.count_statement = attrs[:count_statement] || nil

      # Extra where statement
      self.extra_orm_options = attrs[:extra_orm_options] || nil

      # Name of exported filename
      self.export_filename = attrs[:export_filename] || DataGrid.export_filename

      # Name of export method - (csv)
      self.export_enabled = attrs[:export_enabled]
    end

    # Add new column
    def add_column(column_field, column_attrs = {})
      self.columns << Column.new(column_field, column_attrs)
    end

    # Assign data
    def data(_data)
      self.in_data = _data
      self.data_class = _data
      self.data_class = _data.class
      self.data_class = _data if _data.class != Array
    end

    # Sorting comes from URL?
    def sorting?
      !self.sort.nil?
    end

    # Any column has filters?
    def filters?
      !self.columns.select{|c| !c.filter.nil?}.empty?
    end

    # Any column has summary?
    def summary?
      !self.columns.select{|c| !c.summary.nil?}.empty?
    end

    # Any column has global summary?
    def global_summary?
      !self.columns.select{|c| !c.global_summary.nil?}.empty?
    end

    # Display footer?
    def footer?
      self.show_footer
    end

    # Get params from request
    def get_params_from_request
      self.per_page = (params["per_page_#{self.name}"] || self.per_page).to_i
      self.page = (params["page_#{self.name}"] || self.page).to_i
      self.sort = params["sort_#{self.name}"] ? params["sort_#{self.name}"].split('_').pop.to_i : self.sort
      self.sort_direction = params["sort_direction_#{self.name}"] || self.sort_direction

      self.columns.each_with_index do |col, col_index|
        col.filter_value = params["filter_#{self.name}_#{col_index}"]
        if params["filter_#{self.name}_#{col_index}_from"] or params["filter_#{self.name}_#{col_index}_to"]
          col.filter_value = params["filter_#{self.name}_#{col_index}_from"].to_s + DataGrid.range_separator +
            params["filter_#{self.name}_#{col_index}_to"].to_s
        end
      end
    end

    # Used in view to show entries from
    def entries_from
      ef = (self.page-1)*self.per_page
      ef.zero? ? 1 : ef
    end

    # Used in view to show entries to
    def entries_to
      if (self.page)*self.per_page > total
        total
      else
        (self.page)*self.per_page
      end
    end

    # Assign data
    def data(_data)
      self.in_data = _data
      self.data_class = _data
      self.data_class = _data.class
      self.data_class = _data if _data.class != Array
    end

    alias :data= :data


    # Prepare data, do sorting, filtering, paging
    def prepare_data
      data_source = nil
      if self.data_class == Array
        require 'data_grid/data_source_array'
        data_source = DataGrid::DataSourceArray.new
      else
        require 'data_grid/data_source_orm'
        data_source = DataGrid::DataSourceORM.new
      end

      data_source.data_grid = self
      data_source.prepare_data
    end


    # Row styler is a column, which is hidden and describes style of the row
    def row_styler
      styler_column = self.columns.select{|col| col.title == :row_styler}

      if styler_column and !styler_column.empty?
        styler_column_index = self.columns.index(styler_column.first)

        self.row_styles = []
        self.out_data.each do |row|
          self.row_styles << row[styler_column_index]
        end

        self.columns.delete_at(styler_column_index)
      end
    end
  end
end
