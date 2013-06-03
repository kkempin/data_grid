module DataGrid
  module Generators
    class CopyViewGenerator < Rails::Generators::Base
      @@root = File.expand_path("../../templates", __FILE__)
      source_root @@root

      desc "Copy views ..."
      
      def copy_view_files
        view_root = File.expand_path('../../../../app/views', __FILE__)
        FileUtils.cp_r(Dir["#{view_root}/data_grid"], 'app/views')
      end
  
    end
  end
end
