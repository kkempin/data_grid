module DataGrid
  module Generators
    class InstallGenerator < Rails::Generators::Base
      @@root = File.expand_path("../../templates", __FILE__)
      source_root @@root

      desc "Copy files ..."

      def copy_initializer
        template "data_grid.rb", "config/initializers/data_grid.rb"
      end

      
      def copy_all_files
        assets_root = File.expand_path('../../../../app/assets', __FILE__)

        # only for Rails = 3.0.x
        if Rails::VERSION::MAJOR == 3 and Rails::VERSION::MINOR.zero?
          copy_file "#{@@root}/stylesheets/data_grid/data_grid_3_0.css", "public/stylesheets/data_grid/data_grid.css"
          copy_file "#{assets_root}/javascripts/data_grid/data_grid.js", "public/javascripts/data_grid/data_grid.js"
          FileUtils.cp_r(Dir["#{assets_root}/stylesheets/data_grid/grid_calendar"], 'public/stylesheets/data_grid')
          FileUtils.cp_r(Dir["#{assets_root}/javascripts/data_grid/grid_calendar"], 'public/javascripts/data_grid')
          FileUtils.cp_r(Dir["#{assets_root}/images/data_grid"], 'public/images')
        end
      end
  
    end
  end
end
