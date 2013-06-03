DataGrid.setup do |config|

  # Default per page
  config.per_page = 20

  # Used in URL in range filter
  config.range_separator = '--#--' 

  # Default columns sortable state
  config.column_sortable = false 

  # Default column summary formatter
  config.column_summary_formatter = 'plain_text'

  # Default sort direction
  config.sort_direction = 'asc'

  # Show table footer
  config.show_footer = true

  # Available per page options
  config.available_per_pages = [[10,10],[20,20],[50,50],[100,100],[500,500]]

  # Method used to save grid state
  config.state_saver_method = 'cookies'

  # Default export filename
  config.export_filename = 'export_to_csv.csv'
end
