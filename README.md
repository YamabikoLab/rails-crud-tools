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
This command will generate the **doc/crud.xlsx** file and the **.crudconfig.yml** file.

```sh
$ bundle exec crud init
```

.crudconfig.yml
```yaml
enabled: true # Enables or disables the CRUD tools functionality
base_dir: doc # The base directory where the CRUD files will be stored
crud_file:
  file_name: crud.xlsx # The name of the CRUD Excel file
  sheet_name: CRUD # The name of the sheet in the CRUD Excel file
  header_bg_color: 00FFCC # The background color for the header in the CRUD Excel file
  font_name: Arial # The font name used in the CRUD Excel file
method_col: Verb # Column indicating the HTTP method
action_col: Controller#Action # Column indicating the controller and action
table_start_col: your_first_table # Column where the table starts
sql_logging_enabled: true # Enables or disables SQL logging for CRUD operations
```

### How It Works

Once integrated, the gem automatically tracks CRUD operations (Create, Read, Update, Delete) performed in your application.   
The diagrams will update dynamically based on these operations, providing you with real-time insights into your application's data flow.

### Automatic Backup

The gem automatically creates backup files when updating the CRUD diagram. When changes are made to the CRUD Excel file:

1. A backup file is created with the `.bak` extension (e.g., `crud.xlsx.bak`)
2. The backup is created before any modifications to the original file
3. If an error occurs during the update, the backup file is used to restore the original file
4. The backup file is automatically removed after a successful update

This ensures that your CRUD diagram data is protected against potential corruption or errors during updates.

## Logs

Please refer to the log file at `log/crud.log`.

## CRUD Macro Workbook

The `tools/crud_macro.xlsm` file is a macro-enabled workbook used for manipulating CRUD diagrams.  
This workbook contains macros that help in managing and visualizing CRUD operations within your application.

### Excel Macro Download

You can download the `crud_macro.xlsm` file from the following link:

[Download crud_macro.xlsm](https://github.com/YamabikoLab/rails-crud-tools/raw/main/tools/crud_macro.xlsm)

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

