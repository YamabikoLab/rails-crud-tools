# Rails::Crud

Welcome to Rails::Crud! This gem provides a tool to automatically update CRUD diagrams as you interact with your application. It simplifies logging and managing CRUD operations seamlessly within a Rails application.

## Installation

Add the gem to the `development` group in your application's Gemfile by including the following lines:

```ruby
gem 'rails-crud', git: 'https://github.com/YamabikoLab/rails-crud', ref: 'fe995a3611afeed47a2b7a90245e3afb97c12dd9'
gem 'rubyXL'
```

Then execute:

```sh
$ bundle install
```

If you are not using Bundler, you can install the gem manually:

```sh
$ gem install rails-crud
```

## Usage

### Setup


### How It Works

Once integrated, the gem automatically tracks CRUD operations (Create, Read, Update, Delete) performed in your application. The diagrams will update dynamically based on these operations, providing you with real-time insights into your application's data flow.

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

