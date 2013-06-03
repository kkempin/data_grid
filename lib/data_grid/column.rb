# Class Column used to define colums in DataGrid

module DataGrid
  class Column

    attr_accessor :field, :title, :sortable, :sort_by, :filter, :filter_data, :filter_value, :filter_by, :style, :summary, :summary_formatter, :formatter, :hide_in_export, :css_class, :global_summary, :auto_filter_hash

    def initialize(column_field, attrs = {})
      self.sortable = attrs[:sortable] || DataGrid.column_sortable 
      self.title = attrs[:title]
      self.field = column_field
      self.sort_by = attrs[:sort_by] || self.field
      self.filter = attrs[:filter]
      self.filter_data = []
      self.style = attrs[:style]
      self.summary = attrs[:summary]
      self.global_summary = attrs[:global_summary]
      self.summary_formatter = attrs[:summary_formatter] || DataGrid.column_summary_formatter
      self.formatter = attrs[:formatter]
      self.filter_by = attrs[:filter_by] || self.field
      self.hide_in_export = attrs[:hide_in_export] || false
      self.css_class = attrs[:css_class] || ''
      self.auto_filter_hash = attrs[:auto_filter_hash]
    end

    def sort_field
      if self.field.class == Symbol
        return self.sort_by ? self.sort_by : self.field
      else
        return self.sort_by
      end
    end
    
    def filter_active?
      !self.filter_value.to_s.split(DataGrid.range_separator).first.blank?
    end
  end
end
