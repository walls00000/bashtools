#!/bin/bash --

if [ ! -d ../../modules ];then
  echo "Please run this from inside the module directory"
  exit 1
fi

module=`pwd |sed 's/.*modules\///'`

write_fixtures_yml() {
  cat << FIN > .fixtures.yml
fixtures:
  symlinks:
    puppet:       "#{source_dir}/../puppet"
    ${module}:    "#{source_dir}"
    stdlib:       "#{source_dir}/../stdlib"
FIN
}

write_rakefile() {
  cat << FIN > Rakefile
require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'

exclude_paths = [
    "pkg/**/*",
    "vendor/**/*",
    "spec/**/*",
]
PuppetLint.configuration.ignore_paths = exclude_paths
PuppetLint.configuration.fail_on_warnings = true
PuppetLint.configuration.send("disable_80chars")
PuppetLint.configuration.log_format = "%{path}:%{linenumber}:%{check}:%{KIND}:%{message}"
PuppetLint.configuration.send('disable_class_inherits_from_params_class')
PuppetLint.configuration.send('disable_autoloader_layout')
PuppetSyntax.exclude_paths = exclude_paths

task :default => [ :lint, :validate, :spec ]
FIN
}

write_gemfile() {
rm Gemfile.lock
  cat << FIN > Gemfile
source 'https://rubygems.org'

gem 'puppet', '3.7.5'
gem 'puppetlabs_spec_helper', '>= 0.1.0'
gem 'puppet-lint', '< 1.1.0'
gem 'facter', '>= 1.7.0'
gem 'rspec',       '< 3'
gem 'rspec-puppet', '2.2.0'
FIN
}

write_spec_helper() {
cat << FIN > spec/spec_helper.rb
require 'puppetlabs_spec_helper/module_spec_helper'

# Uncomment to enable coverage
# Note: Due to limitations of rspec-puppet coverage, profiles report incorrect coverage due to fixtures
at_exit { RSpec::Puppet::Coverage.report! }
FIN
}
rspec-puppet-init
write_spec_helper
write_rakefile
write_gemfile
gem install rspec-puppet
bundle install --path vendor/gems
write_fixtures_yml
bundle exec rake spec_prep

echo "This should now work"
echo "bundle exec rake spec 2>&1 | less"

