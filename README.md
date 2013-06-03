# DataGrid

This gem generates configurable grids for Rails applications using as a data source an array or ORM scope (tested only with ActiveRecord). Some basic features:

* Data source can by Array or ActiveRecord::Relation
* Columns have sorting and filtering options
* Paging and initial sorting
* Page or global column summary
* Export to CSV (customizable file name)
* Saving state (like page/per page/sorting) in cookies

## Requisites

* Rails 3.0 (works on Rails 4.0 with some deprecation warnings).

## Installation

Add this line to your application's Gemfile:

    gem 'data_grid'

Execute:

	$ bundle install
	$ rails generate date_grid:install

If Rails version >= 3.1:

  Add to app/assets/javascripts/application.js:

    //= require data_grid/data_grid
    //= require data_grid/grid_calendar/calendar
    //= require data_grid/grid_calendar/calendar-setup
    //= require data_grid/grid_calendar/lang/calendar-en


  Add to app/assets/stylesheets/application.css:

     *= require data_grid/data_grid
     *= require data_grid/grid_calendar/calendar-blue

If Rails version < 3.1:

  You don't need to do anything. Installation script already copied all assets (images, javascripts, stylesheets) to public/ directory.


## Customization

Installation script added initializer "config/initializers/data\_grid.rb". Check this file to modify some configuration settings.

To customize grid layout execute:

    $ rails generate data_grid:copy_view

and modify file app/views/data\_grid/\_data\_grid.html.erb

## Usage

Definition of data\_grid have to be put into action definition in controller.

    class UsersController < ApplicationController
      def index
        @data_grid = prepare_grid do |grid|
          grid.add_column :auto
          grid.add_column :name, :title => 'Name', :sortable => true 
          grid.add_column :surname, :title => 'Surname', :sortable => true, :filter => :text
          grid.add_column :email, :title => 'E-mail'
          grid.add_column :birth_date, :title => 'Date of birth', :formatter => :date, :filter => :date, :sortable => true
          grid.add_column :admin, :title => 'Admin?', :filter => :boolean

          grid.initial_sort = "users.created_at DESC"

          grid.data = User.scoped
        end
      end
    end


and then in view index.html.erb

    <%= show_grid @data_grid %>


## DataGrid definition methods/attributes

* add\_column(data\_source, column\_params) - add new column
* initial\_sort - initial sorting
* export\_enabled = 'csv' - shows icon in grid footer, which clicked generates CSV from grid data
* export\_filename = 'users.csv' - file name of CSV
* per\_page - initial per page
* state\_saver = 'cookies' - page, per\_page and sorting is stored in cookies. When user display page with grid this options are restored from cookies
* data = ... - provides data to display. It can be an array (User.all) or ActiveRecord::Relation (User.scoped / User.where(:name => 'John').load in Rails4)
* name - grid name (optional). Has to be provided if more than one data grid is on the page
* hidden\_row = :method - method with provided name is called on every object. Output of this function is displayed below row which represents object from data source


## Column attributes

* First attribute is column data source. It can be symbol which is model field, or it can be lambda with two parameters. First is each data object, second is view context, which gives possibility of running helpers. For example:

      `grid.add_column lambda{|obj, h| h.link_to(obj.name, users_path(obj), :class => 'user') }, :title => 'Link to user'`

* title - column header title
* sortable - boolean value
* sort\_by - symbol or SQL statement which gives base to sort

      `grid.add_column :name, :title => 'Name', :sortable => true, :sort_by => :surname`

* filter - column filtering method
* filter\_by - symbol or SQL statement which gives base to filter

      `grid.add_column :name, :title => 'Name', :filter => :text, :filter_by => '(SELECT comments.author FROM comments WHERE comments.user_id = users.id LIMIT 1)'`

* style - defines CSS for each cell in this column
* summary - defines method of summaraizing data on current page in this column. Available methods: :average, :sum, :sum\_price
* global\_summary - defines method of summaraizing data from all pages in this column
* formatter - defines method of formatting data from this column. Available methods: :plain\_text, :bold, :money\_pl, :datetime, :date
* summary\_formatter - defines method of formatting data in summaries
* hide\_in\_export - boolean value, if column is hidden in export
* css\_class - defines CSS class for each cell in this column
* auto\_filter\_hash - provides hash used to override auto filter options

      `grid.add_column :name, :title => 'Name', :filter => :auto, :auto_filter_hash => {:"John" => "John D."}`


## Column filter types

* :auto - takes all uniq values from column and display in filters section as select. Displayed values can be overwritten by auto\_filter\_hash option in column definition
* :text - simple input text filter
* :boolean - All/Yes/No values to select
* :number - text input to enter a number
* :range - two inputs to enter range values (from - to)
* :date - two calendar icons for from and to dates. After clicking on icon javascript calendar shows. Calendar comes from www.dynarch.com


## Special column types

* First option in column definition is a data source. There is a special column defined by putting as a first parameter :auto. It prints column with consecutive numbers on current page.
* If you put :row\_styler as column title, column will be not shown, but data generated by this column will be using as row CSS styling:

      `grid.add_column lambda{|x, h| x.price > 50 ? 'color: #f00;' : 'color: #0f0;'}, :title => :row_styler`


## Adding own summaraizing functions

Add file config/initializers/data\_grid\_summaries.rb:

    module DataGrid
      class Summaries

        def self.size_of_column(data_as_array)
          data_as_array.size.to_s
        end

      end
    end


Any method is a summary method. It has one parameter - column data on current page. It has to return a string.
  

## Adding own formatters

Add file config/initializers/data\_grid\_formatters.rb:

    module DataGrid
      class ViewHelpers
      
        def data_grid_formatter_em(txt)
          "<em>#{txt}</em>".html_safe
        end

      end
    end


Any method is a formatter method. It has one parameter - cell data. Method name has to begin with `data\_grid\_formatter\_`. When you using this formatter you hasve to skip this beginning. It has to return a string.

## Integration of the data grid with other forms on page

DataGrid provides view helper

    data_grid_dump_as_hidden_fields(data_grid, except = [])

which renders all necessary fields from data\_grid as input with type hidden.
With this simpled method you can have other forms on page which sends data\_grid state.

## TODO

* More tests

## Contributing 

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

This gem is licensed under the MIT License.
