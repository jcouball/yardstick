# frozen_string_literal: true

require 'yaml'
require 'rspec/core/rake_task'
require 'reek/rake/task'
require 'rubocop/rake_task'
require 'yard'
require 'yardstick/rake/measurement'
require 'yardstick/rake/verify'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec/{unit,integration}/**/*_spec.rb'
end

namespace :spec do
  RSpec::Core::RakeTask.new(:unit) do |t|
    t.pattern = 'spec/unit/**/*_spec.rb'
  end

  RSpec::Core::RakeTask.new(:integration) do |t|
    t.pattern = 'spec/integration/**/*_spec.rb'
  end
end

YARD::Rake::YardocTask.new

yardstick_options = YAML.load_file('config/yardstick.yml')

namespace :metrics do
  RuboCop::RakeTask.new(:rubocop) do |t|
    t.options = ['--config', 'config/rubocop.yml']
  end

  Reek::Rake::Task.new(:reek) do |t|
    t.config_file  = 'config/reek.yml'
    t.source_files = 'lib/**/*.rb'
  end

  namespace :yardstick do
    Yardstick::Rake::Measurement.new(:measure, yardstick_options)
    Yardstick::Rake::Verify.new(:verify, yardstick_options)
  end
end

task ci: %w[metrics:rubocop metrics:yardstick:verify spec:integration]

task default: :spec
