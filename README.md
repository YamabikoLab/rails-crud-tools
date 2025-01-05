# Rails::Crud::Tools

Welcome to Rails::Crud::Tools!   
This gem provides a tool to automatically update CRUD diagrams as you interact with your application.   
It simplifies logging and managing CRUD operations seamlessly within a Rails application.

## Installation

Add the gem to the `development` group in your application's Gemfile by including the following lines:

```ruby
gem 'rails-crud-tools'
```

Then execute:

```sh
$ bundle install
```

If you are not using Bundler, you can install the gem manually:

```sh
$ gem install rails-crud-tools
```

## Usage

### Setup
This command will generate the **doc/crud.xlsx** file and the **.crudconfig** file.

```sh
$ bundle exec crud init
```

.crudconfig
```yaml
enabled: true # Enables or disables the CRUD tools functionality
base_dir: doc # The base directory where the CRUD files will be stored
crud_file: crud.xlsx # The name of the CRUD Excel file
sheet_name: CRUD # The name of the sheet in the CRUD Excel file
method_col: Verb # Column indicating the HTTP method
action_col: Controller#Action # Column indicating the controller and action
table_start_col: your_first_table  # Column where the table starts
header_bg_color: 00FFCC # The background color for the header in the CRUD Excel file
sql_logging_enabled: true # Enables or disables SQL logging for CRUD operations
font_name: Arial # The font name used in the CRUD Excel file
```

### How It Works

Once integrated, the gem automatically tracks CRUD operations (Create, Read, Update, Delete) performed in your application.   
The diagrams will update dynamically based on these operations, providing you with real-time insights into your application's data flow.

## Logs

Please refer to the log file at `log/crud.log`.

## CRUD Macro Workbook

The `tools/crud_macro.xlsm` file is a macro-enabled workbook used for manipulating CRUD diagrams.  
This workbook contains macros that help in managing and visualizing CRUD operations within your application.

### Download

You can download the `crud_macro.xlsm` file from the following link:

[Download crud_macro.xlsm](https://github.com/YamabikoLab/rails-crud-tools/raw/main/tools/crud_macro.xlsm)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run the following command to execute the tests:

```sh
$ rake spec
```

You can also use `bin/console` for an interactive prompt to experiment with the gem’s functionality.

To install this gem onto your local machine for development purposes, run:

```sh
$ bundle exec rake install
```

To release a new version:
1. Update the version number in `version.rb`.
2. Run:

```sh
$ bundle exec rake release
```

This will create a git tag for the new version, push the git commits and tag, and upload the `.gem` file to [RubyGems](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/YamabikoLab/rails-crud](https://github.com/YamabikoLab/rails-crud).

When contributing, please:
- Fork the repository.
- Create a feature branch.
- Submit a pull request with a clear description of your changes.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

