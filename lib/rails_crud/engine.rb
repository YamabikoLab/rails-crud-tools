module RailsCrud
  class Engine < ::Rails::Engine
    initializer 'rails_crud.assets.precompile' do |app|
      app.config.assets.precompile += %w(rails_crud.js)
    end
  end
end