OSX build box for dd-agent-omnibus
==================================

This repository consists in a (very basic) chef cookbook as well as a shell script
aimed at provisioning any OSX machine to make it an Omnibus builder for dd-agent
and a Vagrantfile to spawn a build VM on the fly.

The provisioning script is going to install chef and a couple of other dependencies
required to pull and run our recipe on the target machine. It's going to install
brew, git go, cask and chefdk. Then it will create a chef repo under ~/chef-repo,
pull this recipe as well as its dependencies (using berkshelf) and run chef-solo
on it. Ultimately, the permissions for ~/.ccache (badly set by the omnibus recipe
will be tweaked), the dd-agent-omnibus Git repo will be pulled and made ready for
and omnibus build. The only thing left to do is just pull the trigger !

How-to use this repository
--------------------------

### With Vagrant
Using Vagrant to get a fresh build machine is pretty straightforward. On the other
hand, the dropdown in computing power using a VM (what's more, an OSX VM running
on VirtualBox) will make the build last twice longer.

Also Virtualbox doesn't make it possible to have shared folders (which is one of
the main reasons why we need to use a shell script instead of using the chef and
Berkshelf vagrant plugins for the early provisioning of our VM). It implies that
destroying your VM will wipe out omnibus' cache, that you will have to fetch your
artifacts using SCP or network-shared folders and a couple of other bad things.

#### Prepare the toolchain to sign the DMG package

To sign the DMG package, you'll need a certificate that matches the signing
identity declared in the `dd-agent-omnibus` project DSL. Importing this one in
vagrant without shared folders is a bit tricky... just a bit :) You have to
hide it in an environment variable called DD_AGENT_DMG_SIGNING_CERT after
replacing the newline characters by escaped `\\n` characters. Here's a script
that could do it, assuming the certificate is under `./mycert.pem`.

```sh
export DD_AGENT_DMG_SIGNING_CERT="$( \
    sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/\\n/g' ./mycert.pem \
)"
```

Please note that it is essential to use a PEM file since it's a text file while
a `.cer` would be a binary one (and binary data doesn't really fit into
environment variables :) ). Import and re-export the key in your Keychain if
you only have a `.cer` file at hand.
The environment variable has do be accessible by the `vagrant up` command.

#### Run the build

To launch a build on Vagrant, just run

```sh
vagrant up && vagrant ssh
```

You'll be logged into the build machine after the provisioning and all is left
for you to do is to run the following command

```sh
AGENT_BRANCH=quentin/macos-build OMNIBUS_BRANCH=etienne/omnibus-4-osx \
    sh ./dd-agent-omnibus/omnibus_build.sh
```

The build will then run. Once completed, you can go fetch the build artifacts
under `/var/cache/omnibus/pkg/`.

### On a standalone machine

#### Requirements

* A GUI environment enabled for the build user (needed because Finder is ran at
  to complete the DMG build and will fail if there's no GUI environment)
  TODO: check if, by smartly modifying the `create_dmg.oascript` resource, there
  could be a way to get rid of the GUI requirement, that'd enable us to use
  CircleCI for our builds and that'd be really cool.

* A build user with sudoers rights without a password (which basically means you
  should have a line like the one below in your sudoers' configuration).

* A signing key in your toolchain whose identity matches the one declared in the
  project DSL for dd-agent-omnibus (Datadog Inc.). This one will be used to sign
  the DMG package.

```
build_user ALL=(ALL) NOPASSWD: ALL
```

#### Using the provisioning script

You can run `./provision.sh` to have your machine setup. By default this will
make the current user an omnibus builder. You can override this behaviour by
setting the `OMNIBUS_USER` environment variable. Once ran, all you have to do is
run the command below and go fetch the build artifacts under
`/var/cache/omnibus/pkg`.

```sh
AGENT_BRANCH=quentin/macos-build OMNIBUS_BRANCH=etienne/omnibus-4-osx \
    sh ./dd-agent-omnibus/omnibus_build.sh
```

##### Note: running chef manually

If, for any reason, you don't want `provision.sh` to run `chef-solo`, just run
the script with the `DISABLE_CHEF_SOLO` environment variable set to `true`.

#### Using only the chef recipe

Alternatively, you can choose to resolve the dependencies by hand (homebrew, git,
gom cask, chefdk, bundler), pull this repo on your machine, run berkshelf to have
all the necessarry cookbooks, setup your chef config as described below and run
chef-solo "manually". Note that you can use the OMNIBUS_USER environment variable
to choose the user that will run the build.

* *solo.rb*: chef-solo configuration file
```ruby
file_cache_path "/Users/build_user/chef-solo"
cookbook_path [
  "/Users/build_user/chef-repo/cookbooks",
  "/Users/build_user/.berkshelf/cookbooks"
]
```

* *osx-build.json*: chef-solo run list
```json
{
  "run_list": ["recipe[osx-dd-agent-build-box"]
}
```

* Cd into your chef repo and run chef-solo (must be ran as sudo)

```sh
cd ~/chef-repo
sudo OMNIBUS_USER=$USER chef-solo -c solo.rb -j osx-build.json
```

Once the chef run is complete, you can pull `dd-agent-omnibus`, install the
binstubs with `bundle install --binstubs` and run the usual command:

```sh
AGENT_BRANCH=quentin/macos-build OMNIBUS_BRANCH=etienne/omnibus-4-osx \
    sh ./dd-agent-omnibus/omnibus_build.sh
```

Notes
-----

* This recipe relies (more than) heavily on the chef omnibus recipe:
  https://github.com/opscode-cookbooks/omnibus

License and Authors
-------------------
Authors:
- Etienne Lafarge
