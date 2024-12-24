namespace :crud do
  desc "Generate CRUD file"
  task :gen => :environment do
    require 'rails/crud'
    Rails::Crud.generate_crud_file
  end
end