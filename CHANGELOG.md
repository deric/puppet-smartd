# Changelog

All notable changes to this project will be documented in this file.


## Release 0.5.0 [2023-12-10]

**Features**

  - Puppet 8 support
  - Debian 12 support

**Bugfixes**

  - Fixed module dependencies
  - Optional param defaults to `undef`


[Full diff](https://github.com/deric/puppet-smartd/compare/v0.4.0...v0.5.0)

## Release 0.4.0 [2022-10-20]

**Features**

  - Support passing package install options

[Full diff](https://github.com/deric/puppet-smartd/compare/v0.3.0...v0.4.0)

## Release 0.3.0 [2022-09-20]

**Bugfixes**

  - Fixed service name on Debian 10
  - Fixed array options serialization

## Release 0.2.0 [2022-09-15]

**Bugfixes**

 - Changed semantics of rules from Hash to Array of Hashes in order to support multiple rules over the same attribute
 - Debian service is called `smartmontools` but `smartd` works as an alias

[Full diff](https://github.com/deric/puppet-smartd/compare/v0.1.0...v0.2.0)


## Release 0.1.0 [2022-09-15]

**Features**

 - Support matching disk attributes and appending smard config flags
 - Support matching by device name
 - Ignore certain devices

**Known Issues**
