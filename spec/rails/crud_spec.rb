# frozen_string_literal: true
require "spec_helper"

RSpec.describe Rails::Crud do
  it "has a version number" do
    expect(Rails::Crud::Tools::VERSION).not_to be nil
  end
end
