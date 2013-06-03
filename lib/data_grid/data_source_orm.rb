# Source od grid data comes from ORM

module DataGrid
  class DataSourceORM
    
    attr_accessor :data_grid

    def prepare_data
      global_summary_orm
      get_data_from_orm
      summary_orm
      self.data_grid.row_styler
      prepare_orm_data_for_filters
    end
 
    
  private

    def direction_as_int
      if self.sort_direction == 'ASC'
        return 1
      else
        return -1
      end
    end
    
    # Filter data using ORM 
    def prepare_orm_filters
      filters = [[]]
      date_format = I18n.t(:"date.formats.default", {:locale => I18n.locale })
      self.data_grid.columns.each_with_index do |col, col_index|
        if col.filter and !col.filter_value.blank?
          case col.filter
          when :boolean
            filters[0] << "#{col.filter_by} = ?"
            filters << (col.filter_value == '1') ? true : false
          when :auto
            filters[0] << "#{col.filter_by} = ?"
            filters << col.filter_value
          when :text
            filters[0] << "#{col.filter_by} #{ActiveRecord::Base.connection.adapter_name.downcase.to_sym == :postgresql ? 'ILIKE' : 'LIKE'} ?"
            filters << "%#{col.filter_value}%"
          when :number
            filters[0] << "#{col.filter_by} = ?"
            filters << col.filter_value.to_i
          when :range
            range = col.filter_value.split(DataGrid.range_separator)

            if !range[0].blank? and !range[1].blank?
              begin
                range[0] < 2
              rescue
                range[0] = range[0].to_f
                range[1] = range[1].to_f
              end
              filters[0] << "#{col.filter_by} >= ? AND #{col.filter_by} <= ?"
              filters << range[0]
              filters << range[1]
            elsif range[0].blank? and !range[1].blank?
              begin
                range[1] < 2
              rescue
                range[1] = range[1].to_f
              end
              filters[0] << "#{col.filter_by} <= ?"
              filters << range[1]
            elsif range[1].blank? and !range[0].blank?
              begin
                range[0] < 2
              rescue
                range[0] = range[0].to_f
              end
              filters[0] << "#{col.filter_by} >= ?"
              filters << range[0]
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
              filters[0] << "#{col.filter_by} >= ? AND #{col.filter_by} <= ?"
              filters << range[0]
              filters << range[1]
            elsif range[0].blank? and !range[1].blank?
              begin
                range[1] < 2
              rescue
                range[1] = DateTime.strptime(range[1], date_format)
              end
              filters[0] << "#{col.filter_by} <= ?"
              filters << range[1]
            elsif range[1].blank? and !range[0].blank?
              begin
                range[0] < 2
              rescue
                range[0] = DateTime.strptime(range[0], date_format)
              end
              filters[0] << "#{col.filter_by} >= ?"
              filters << range[0]
            end
          end
        end
      end
      
      filters[0] = filters[0].join(' AND ')
      filters
    end
    
    # Get data
    def get_data_from_orm
      self.data_grid.out_data = []
      
      # prepare filters as ActiveRecord conditions 
      filters = prepare_orm_filters
      self.data_grid.total = self.data_grid.in_data.where(filters).where(self.data_grid.extra_orm_options).count(self.data_grid.count_statement)
      self.data_grid.page = 1 if ((self.data_grid.per_page * (self.data_grid.page - 1)) > self.data_grid.total)
      offset = (self.data_grid.page - 1) * self.data_grid.per_page

      
      # get data sorted
      if self.data_grid.sorting?
        self.data_grid.in_data = self.data_grid.in_data.limit(self.data_grid.per_page.to_i).offset(offset.to_i).order("#{self.data_grid.columns[self.data_grid.sort].sort_field} #{self.data_grid.sort_direction}" + (self.data_grid.initial_sort.blank? ? '' : ", #{self.data_grid.initial_sort}")).where(filters).where(self.data_grid.extra_orm_options)
      else
        self.data_grid.in_data = self.data_grid.in_data.limit(self.data_grid.per_page.to_i).offset(offset.to_i).where(filters).order(self.data_grid.initial_sort.blank? ? '' : "#{self.data_grid.initial_sort}").where(self.data_grid.extra_orm_options)
      end

      # prepare out data array, eval lambdas
      self.data_grid.in_data.each_with_index do |obj, row_index|
        row = []
        self.data_grid.columns.each do |col|
          if col.field.class == Symbol
            if col.field == :auto
              row << row_index + 1 + (self.data_grid.page-1)*self.data_grid.per_page
            else
              row << obj.send(col.field)
            end
          else
            row << col.field.call(obj, self.data_grid.view_context)
          end 
        end

        # Hidden rows
        unless self.data_grid.hidden_row.nil?
          self.data_grid.out_hidden_rows << obj.send(self.data_grid.hidden_row) 
        end
        
        self.data_grid.out_data << row
      end
      
      self.data_grid.pages = (self.data_grid.total/self.data_grid.per_page.to_f).ceil
    end
    
    # Prepare data for filters
    def prepare_orm_data_for_filters
      self.data_grid.columns.each do |col|
        next if col.filter.nil? # if no filter

        # Prepare auto filters
        if col.filter == :auto
          col.filter_data = self.data_grid.data_class.select("DISTINCT (#{col.filter_by}) as fc").to_a.to_a.map(&:fc)
        end

        col.filter_data.uniq!
        col.filter_data.sort!
      end
    end
  
    # Summary
    def summary_orm
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
    def global_summary_orm
      if self.data_grid.global_summary?
        # prepare filters as ActiveRecord conditions 
        filters = prepare_orm_filters

        self.data_grid.global_summaries = []
        self.data_grid.columns.each_with_index do |col, col_index|
          if col.global_summary
            self.data_grid.global_summaries[col_index] = self.data_grid.in_data.scoped(:conditions => filters).where(self.data_grid.extra_orm_options).send(*col.global_summary)
          end
        end
      end
    end
  end
end

