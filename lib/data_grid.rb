require "data_grid/version"
require "data_grid/engine"
require "data_grid/controller"
require "data_grid/data_grid_logic"
require "data_grid/column"
require "data_grid/summaries"
require "data_grid/view_helpers"

module DataGrid

  # Default per page
  mattr_accessor :per_page

  # Used in URL in range filter
  mattr_accessor :range_separator

  # Default columns sortable state
  mattr_accessor :column_sortable

  # Default column summary formatter
  mattr_accessor :column_summary_formatter

  # Default sort direction
  mattr_accessor :sort_direction

  # Show table footer
  mattr_accessor :show_footer

  # Available per page options
  mattr_accessor :available_per_pages

  # Method used to save grid state
  mattr_accessor :state_saver_method

  # Default export filename
  mattr_accessor :export_filename


  def self.setup
    yield self
  end

end
