module DataGrid
  class Engine < Rails::Engine

    initializer "data_grid.action_controller" do
      ActiveSupport.on_load(:action_controller) do
        include DataGrid::Controller
      end
    end

    initializer "data_grid.view_helpers" do
      ActionView::Base.send :include, DataGrid::ViewHelpers
    end

    initializer "static assets" do |app|
      app.middleware.use ::ActionDispatch::Static, "#{root}/public"
    end

  end
end
