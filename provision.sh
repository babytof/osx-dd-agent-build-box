#!/bin/bash
echo "#### STARTING BASH PRE-PROVISIONING OF THE OSX BUILD VM ####"

echo "##### Cleaning up remains from a previous provisionning"
sudo rm -rf ~/chef-solo ~/chef-repo ~/dd-agent-omnibus ~/.bundler

echo "##### Create chef-solo directory"
mkdir ~/chef-solo

# Let's get on with dependencies
if !(command -v brew >/dev/null 2>&1) ; then
  echo "##### Homebrew is not install, let's download it!"
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

echo "##### Install git via Homebrew"
brew install git
echo "##### Install go via Homebrew"
brew install go

echo "##### Install cask via Homebrew"
brew install caskroom/cask/brew-cask jq
echo "##### Install chefdk via cask"
brew cask install chefdk
echo "##### Print chef-solo version: "
chef-solo -v

# Bundler is always necessary (gem should be installed as part of chefdk)
echo "##### Installing bundler using Rubygem (previously installed with chefdk)"
sudo gem install bundler

# Let's setup a chef repo
echo "##### Setting up a new chef repository under $HOME/chef-repo"
cd $HOME && curl -L -o master https://github.com/chef/chef-repo/tarball/master
tar -zxf master && mv chef-chef-repo* chef-repo && rm master

# Let's prepare the build
echo "##### Configuring chef-solo to run our \"osx-dd-agent-build-box\" recipe"
cd ~/chef-repo/cookbooks && git clone https://github.com/DataDog/osx-dd-agent-build-box.git
cd osx-dd-agent-build-box && berks install
cd ~/chef-repo
echo "file_cache_path \"$HOME/chef-solo\"
cookbook_path [\"$HOME/chef-repo/cookbooks\", \"$HOME/.berkshelf/cookbooks\"]" > solo.rb
echo "{\"run_list\": [ \"recipe[osx-dd-agent-build-box]\" ]}" > osx-build.json

# Let's provision the beast !
if [ -n "$OMNIBUS_USER" ] && [ ${#OMNIBUS_USER} > 0 ]; then
  echo "##### OMNIBUS_USER is set to \"$OMNIBUS_USER\" -> Configuring omnibus for this user."
  BUILD_USER=$OMNIBUS_USER
elif [ -n "$USER" ]; then
  echo "##### OMNIBUS_USER is not set -> Configuring omnibus for the user \"$USER\"."
  BUILD_USER=$USER
else
  echo "##### OMNIBUS_USER is not set, neither is USER. Configuring omnibus to be run by the \"omnibus\" user."
  BUILD_USER='omnibus'
fi

# Let's source environment variables potentially passed through a vagrant host
if [ -e "$HOME/env_passthrough.sh" ]; then
    source $HOME/env_passthrough.sh
fi

# Let's add the signing certificate if needed
if [ -n "$DD_AGENT_DMG_SIGNING_CERT" ] && [ ${#DD_AGENT_DMG_SIGNING_CERT} > 0 ]; then
  echo "##### Found DD_AGENT_DMG_SIGNING_CERT environment variable."
  echo "###### Unpacking environment variable into ~/dd-agent-dmg-signing.pem"
  echo -e $DD_AGENT_DMG_SIGNING_CERT > ~/dd-agent-dmg-signing.pem
  echo "###### Importing certificate into Keychain... "
  sudo security import ~/dd-agent-dmg-signing.pem -A -k /Library/Keychains/System.keychain
  echo "###### Deleting file ~/dd-agent-dmg_signing.pem"
  rm ~/dd-agent-dmg-signing.pem
fi

if [ -z "$DISABLE_CHEF_SOLO" ] || !$DISABLE_CHEF_SOLO; then
  echo "#### END OF BASH PRE-PROVISIONING, LET'S HAVE CHEF HANDLE THE REST FOR US ####"
  sudo OMNIBUS_USER=$BUILD_USER chef-solo -c solo.rb -j osx-build.json
else
  echo "
#### END OF BASH PRE-PROVISIONNING. DISBALE_CHEF_SOLO is set to false,
     chef-solo hasn't been run. To do it manually please type:

         sudo OMNIBUS_USER=$BUILD_USER chef-solo -c solo.rb -j osx-build.json

"
fi

echo "#### GREAT SUCCESS : the provisionning script has exited with status code 0."

exit 0
