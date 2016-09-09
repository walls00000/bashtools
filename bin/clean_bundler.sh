# remove user-specific gems and git repos
rm -rf ~/.bundle/ ~/.gem/bundler/ ~/.gems/cache/bundler/

# remove system-wide git repos and git checkouts
rm -rf $GEM_HOME/bundler/ $GEM_HOME/cache/bundler/

# remove project-specific settings
rm -rf .bundle/

# remove project-specific cached gems and repos
rm -rf vendor/cache/

# remove the saved resolve of the Gemfile
rm -rf Gemfile.lock

# uninstall the rubygems-bundler and open_gem gems
#rvm gemset use global # if using rvm
#gem uninstall rubygems-bundler open_gem

# try to install one more time
echo "bundle install"
