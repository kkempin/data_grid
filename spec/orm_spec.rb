require 'active_support'
require 'support/active_record'
require 'data_grid/data_grid_logic'
require 'data_grid/data_source_orm'

describe DataGrid::DataSourceORM do
  it "selects right data source (ORM)" do
    data_grid_logic = DataGrid::DataGridLogic.new(:params => ActiveSupport::HashWithIndifferentAccess.new())
    data_grid_logic.add_column(:name, :title => 'Name')
    data_grid_logic.data = User.scoped

    data_grid_logic.in_data.class.should eql(ActiveRecord::Relation)
  end
 
  it "paginate 10 per page from configuraion" do
    data_grid_logic = DataGrid::DataGridLogic.new(:params => ActiveSupport::HashWithIndifferentAccess.new(:"page_" => '1'))
    data_grid_logic.add_column(:name, :title => 'Name')
    data_grid_logic.per_page = 10
    data_grid_logic.data = User.scoped
    data_grid_logic.get_params_from_request
    data_grid_logic.prepare_data

    data_grid_logic.out_data.size.should eql(10)
  end

  it "paginate 10 per page from params" do
    data_grid_logic = DataGrid::DataGridLogic.new(:params => ActiveSupport::HashWithIndifferentAccess.new(:"page_" => '1', :"per_page_" => '10'))
    data_grid_logic.add_column(:name, :title => 'Name')
    data_grid_logic.per_page = 20
    data_grid_logic.data = User.scoped
    data_grid_logic.get_params_from_request
    data_grid_logic.prepare_data

    data_grid_logic.out_data.size.should eql(10)
  end

  it "paginate correct data and sort correctly" do
    data_grid_logic = DataGrid::DataGridLogic.new(:params => ActiveSupport::HashWithIndifferentAccess.new(:"page_" => '2', :"per_page_" => '10', :"sort_" => 'name', :"sort_direction_" => 'ASC'))
    data_grid_logic.add_column(:name, :title => 'Name')
    data_grid_logic.data = User.scoped
    data_grid_logic.get_params_from_request
    data_grid_logic.prepare_data

    data_grid_logic.out_data.first[0].should eql('John_19')
  end

  it "filter text method" do
    data_grid_logic = DataGrid::DataGridLogic.new(:params => ActiveSupport::HashWithIndifferentAccess.new(:"page_" => '1', :"per_page_" => '10', :"filter__0" => '9', :"sort_" => 'name', :"sort_direction_" => 'ASC'))
    data_grid_logic.add_column(:name, :title => 'Name', :filter => :text)
    data_grid_logic.data = User.scoped
    data_grid_logic.get_params_from_request
    data_grid_logic.prepare_data

    data_grid_logic.out_data.size.should eql(5)
    data_grid_logic.out_data.first[0].should eql('John_19')
  end
end
