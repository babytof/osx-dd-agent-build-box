#!/bin/bash

echo "#### STARTING BASH PROVISIONING OF OUR OSX BUILD VM ####"

sudo rm -rf ~/chef-solo ~/chef-repo ~/dd-agent-omnibus ~/.bundler

mkdir ~/chef-solo

# Let's get on with dependencies
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

brew install git
brew install go

brew install caskroom/cask/brew-cask jq
brew cask install chefdk

# Bundler is always necessary
sudo gem install bundler

# Let's install chef
curl -L https://www.opscode.com/chef/install.sh | bash
chef-solo -v
curl -L -o master https://github.com/chef/chef-repo/tarball/master
tar -zxf master && mv chef-chef-repo* chef-repo && rm master


# Let's prepare the build
cd ~/chef-repo/cookbooks && git clone https://github.com/DataDog/osx-dd-agent-build-box.git
cd osx-dd-agent-build-box && berks install
cd ~/chef-repo
echo 'file_cache_path "/Users/vagrant/chef-solo"
cookbook_path ["/Users/vagrant/chef-repo/cookbooks", "/Users/vagrant/.berkshelf/cookbooks"]' > solo.rb
echo '{"run_list": [ "recipe[osx-dd-agent-build-box]" ]}' > osx-build.json
sudo chef-solo -c solo.rb -j osx-build.json

# This line's a nasty one but I didn't find a cleaner workaround... there should
# be one since we don't have to do it on the physical build machine but I
# couldn't find it so far
chown -R vagrant:nouser /Library/Ruby/Gems/2.0.0/bundler/gems/

# Oh, and let's clone dd-agent omnibus by the way, and also install binstubs for it
cd ~
git clone https://github.com/DataDog/dd-agent-omnibus.git
cd dd-agent-omnibus
git checkout etienne/omnibus-4-migration
bundle install --binstubs

echo "#### END OF BASH PROVISIONING, LET'S HAVE CHEF HANDLE THE REST FOR US ####"

exit 0
