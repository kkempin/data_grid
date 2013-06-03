# State consists of actual per_page, page, sort, sort direction of DataGrid

module DataGrid
  module Controller

    STATE_KEYS = [:per_page, :page, :sort, :sort_direction]

    # Save grid state in cookies
    def save_state(data_grid)
      cookies["data_grid_state_#{data_grid.name}"] ||= {}
    
      state = {}
      STATE_KEYS.each do |key|
        state[key] = data_grid.send(key)
      end
      
      data_grid.columns.each_with_index do |col, col_index|
        state[:columns] ||= {}
        state[:columns][col_index] = col.filter_value
      end
      
      cookies["data_grid_state_#{data_grid.name}"] = Marshal.dump(state)
    end
  
    # Restore state from cookies
    def restore_state(data_grid)
      if cookies["data_grid_state_#{data_grid.name}"]
        state = Marshal.load(cookies["data_grid_state_#{data_grid.name}"])
        STATE_KEYS.each do |key|
          data_grid.send("#{key}=", state[key])
        end
      
        if state[:columns]
          state[:columns].each_pair do |k, v|
            data_grid.columns[k.to_i].filter_value = v if data_grid.columns[k.to_i]
          end
        end
      end
    end
  end
end

