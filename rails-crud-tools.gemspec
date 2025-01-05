# frozen_string_literal: true

require_relative "./lib/rails/crud/tools/version"

Gem::Specification.new do |spec|
  spec.name = "rails-crud-tools"
  spec.version = Rails::Crud::Tools::VERSION
  spec.authors = ["yhijikata"]
  spec.email = ["yhijikata@systemlancer.com"]

  spec.summary = "A crud diagram is created simply by manipulating the screen."
  spec.description = "This gem provides CRUD functionality for Rails applications."
  spec.homepage = "https://github.com/YamabikoLab"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/YamabikoLab/rails-crud-tools"
  spec.metadata["changelog_uri"] = "https://github.com/YamabikoLab/rails-crud-tools/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "activerecord", "~> 7.0"
  spec.add_runtime_dependency "rubyXL", "~> 3.4"
  spec.add_runtime_dependency "rubyzip", "~> 2.4"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
