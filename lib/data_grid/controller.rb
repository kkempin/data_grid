module DataGrid
  module Controller
    extend ActiveSupport::Concern

    def prepare_grid(&block)
      # Build logic object
      data_grid = DataGrid::DataGridLogic.new(:params => params)
      block.call(data_grid)

      # Restore state
      if data_grid.state_saver and DataGrid.state_saver_method
        require "data_grid/#{DataGrid.state_saver_method}_state_saver"
        self.restore_state(data_grid)
      end

      # Get and save data from params
      data_grid.get_params_from_request
      self.save_state(data_grid) if data_grid.state_saver

      # Export on demand
      if data_grid.export_enabled and params["export_#{data_grid.name}"]
        require "data_grid/#{params["export_#{data_grid.name}"]}_exporter"
        self.export(data_grid, data_grid.export_filename)
      end
      
      data_grid
    end

  end
end
