dd-agent-osx-build-box Cookbook
===============================

This cookbook sets up an OSX machine (10.7 Lion or superior) to be an Omnibus build machine for the Datadog agent. It basically installs some dependencies, omnibus itself, creates a few necessary directories, pulls and runs the omnibus build.

Requirements
------------
CPU: x64 2 Cores @ 2GHz or more
Memory: 2GB

Software:
- OSX Lion 10.7 (or more recent version)
- Vagrant

Attributes
----------
TODO: List your cookbook attributes here.

e.g.
#### dd-agent-osx-build-box::default
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['dd-agent-osx-build-box']['bacon']</tt></td>
    <td>Boolean</td>
    <td>whether to include bacon</td>
    <td><tt>true</tt></td>
  </tr>
</table>

Usage
-----
#### dd-agent-osx-build-box::default
TODO: Write usage instructions for each cookbook.

e.g.
Just include `dd-agent-osx-build-box` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[dd-agent-osx-build-box]"
  ]
}
```

License and Authors
-------------------
Authors:
- Etienne Lafarge
