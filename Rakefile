# frozen_string_literal: true

require 'yaml'
require 'flay'
require 'flay_task'
require 'flog'
require 'rspec/core/rake_task'
require 'reek/rake/task'
require 'rubocop/rake_task'
require 'yard'
require 'yardstick/rake/measurement'
require 'yardstick/rake/verify'

require 'bundler/gem_tasks'

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
  desc 'Analyze code complexity with flog'
  task :flog do
    flog_options = YAML.load_file('config/flog.yml')
    threshold    = flog_options.fetch('threshold', 10)
    flog         = Flog.new(continue: true)
    flog.flog(*Flog.expand_dirs_to_files('lib'))

    average = flog.average

    raise "Flog average #{average.round(1)} exceeds threshold #{threshold}" unless average <= threshold

    puts "Passed flog (average: #{average.round(1)}, threshold: #{threshold})"
  end

  flay_options = YAML.load_file('config/flay.yml')

  FlayTask.new(:flay) do |t|
    t.dirs      = ['lib']
    t.threshold = flay_options.fetch('threshold', 0)
  end

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

  desc 'Run full spec suite with coverage enforcement (minimum 100%)'
  task :coverage do
    ENV['COVERAGE'] = 'true'
    Rake::Task[:spec].invoke
  end

  desc 'Run mutation testing with mutant'
  task :mutant do
    mutant_options = YAML.load_file('config/mutant.yml')
    namespace_subject = mutant_options.fetch('namespace', 'Yardstick')
    gem_name          = mutant_options.fetch('name', 'yardstick')
    args = %W[
      mutant run
      --include lib
      --require #{gem_name}
      --use rspec
      --usage opensource
      #{namespace_subject}
    ]
    sh(*args)
  end
end

task ci: %w[
  metrics:rubocop
  metrics:reek
  metrics:flay
  metrics:flog
  metrics:yardstick:verify
  metrics:coverage
]

# metrics:mutant is intentionally excluded from ci — mutation testing
# is slow and should be run separately as needed.

task default: :spec

require 'English'

desc 'Build and install the yardstick gem and run a sanity check'
task 'test:gem': :install do
  output = `ruby -e "require 'yardstick'; puts Yardstick::VERSION"`.chomp
  raise 'Gem test failed' unless $CHILD_STATUS.success?
  raise 'Expected gem test to return a version string' unless output =~ /^\d+\.\d+\.\d+$/

  puts 'Gem Test Succeeded'
end
