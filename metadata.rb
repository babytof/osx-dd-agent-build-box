name             'osx-dd-agent-build-box'
maintainer       'Datadog Packages (Etienne Lafarge)'
maintainer_email 'etienne.lafarge@datadoghq.com'
license          'Simplified BSD License'
description      'Makes any OSX machine a dd-agent DMG omnibus-builder.'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends "omnibus"
