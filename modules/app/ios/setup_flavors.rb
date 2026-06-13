#!/usr/bin/env ruby
# One-shot generator for iOS flavors (dev / staging / prod).
#
# Adds per-flavor build configurations (Debug-<flavor>, Release-<flavor>,
# Profile-<flavor>) to the project + Runner + RunnerTests, each with its own
# bundle id and display name, then creates shared schemes named after each
# flavor so `flutter run --flavor <flavor>` works.
#
# Run with the xcodeproj gem on the load path:
#   GEM_HOME=/tmp/mapka-gems ruby ios/setup_flavors.rb
require 'xcodeproj'

PROJECT_PATH = File.join(__dir__, 'Runner.xcodeproj')
BASE_BUNDLE_ID = 'com.croxoner.mapka'
BASES = %w[Debug Release Profile].freeze
FLAVORS = {
  'dev'     => { suffix: '.dev',     name: 'Mapka Dev' },
  'staging' => { suffix: '.staging', name: 'Mapka Staging' },
  'prod'    => { suffix: '',         name: 'Mapka' },
}.freeze

project = Xcodeproj::Project.open(PROJECT_PATH)
runner = project.targets.find { |t| t.name == 'Runner' }
tests  = project.targets.find { |t| t.name == 'RunnerTests' }

def clone_config(list, base_name, new_name)
  base = list.build_configurations.find { |c| c.name == base_name }
  raise "Missing base config #{base_name}" unless base

  conf = list.build_configurations.find { |c| c.name == new_name }
  unless conf
    conf = list.project.new(Xcodeproj::Project::Object::XCBuildConfiguration)
    conf.name = new_name
    list.build_configurations << conf
  end
  # Reset from the base each run so re-runs stay clean (no stale keys).
  conf.build_settings = base.build_settings.dup
  conf.base_configuration_reference = base.base_configuration_reference
  conf
end

# Reset the plain (non-flavor) base configs to the project's identity.
runner.build_configuration_list.build_configurations.each do |c|
  next unless BASES.include?(c.name)

  c.build_settings['APP_DISPLAY_NAME'] = 'Mapka'
  c.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = BASE_BUNDLE_ID
end
tests.build_configuration_list.build_configurations.each do |c|
  next unless BASES.include?(c.name)

  c.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = "#{BASE_BUNDLE_ID}.RunnerTests"
end

FLAVORS.each do |flavor, info|
  BASES.each do |base|
    name = "#{base}-#{flavor}"

    clone_config(project.build_configuration_list, base, name)

    rc = clone_config(runner.build_configuration_list, base, name)
    rc.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = "#{BASE_BUNDLE_ID}#{info[:suffix]}"
    rc.build_settings['APP_DISPLAY_NAME'] = info[:name]

    tc = clone_config(tests.build_configuration_list, base, name)
    tc.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = "#{BASE_BUNDLE_ID}#{info[:suffix]}.RunnerTests"
  end
end

project.save

# Shared schemes — one per flavor, mapping each action to its flavor config.
FLAVORS.each_key do |flavor|
  scheme = Xcodeproj::XCScheme.new
  scheme.add_build_target(runner)
  scheme.add_test_target(tests)
  scheme.set_launch_target(runner)

  scheme.test_action.build_configuration    = "Debug-#{flavor}"
  scheme.launch_action.build_configuration  = "Debug-#{flavor}"
  scheme.analyze_action.build_configuration = "Debug-#{flavor}"
  scheme.profile_action.build_configuration = "Profile-#{flavor}"
  scheme.archive_action.build_configuration = "Release-#{flavor}"

  scheme.save_as(PROJECT_PATH, flavor, true)
end

puts "Done: added #{FLAVORS.size * BASES.size} configs/target and #{FLAVORS.size} schemes."
