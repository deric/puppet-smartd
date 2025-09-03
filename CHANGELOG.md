# Changelog

All notable changes to this project will be documented in this file.

## Release 2.1.0 [2025-09-03]

 - Avoid forcing `-d ata` type to ata devices (can be done using rules)

[Full diff](https://github.com/deric/puppet-smartd/compare/v2.0.0...v2.1.0)


## Release 2.0.0 [2025-09-03]

 - Deep merge for `smartd::rules`
 - Add support for Debian 13, Ubuntu 24.04, RedHat 9
 - Drop Debian 10, CentOS 7 support

[Full diff](https://github.com/deric/puppet-smartd/compare/v1.1.0...v2.0.0)


## Release 1.1.0 [2024-11-03]

 - Replace `stdlib::ensure_packages` with `ensure_resources` which doesn't require stdlib >=9
 - Use hierarchical facts in tests

[Full diff](https://github.com/deric/puppet-smartd/compare/v1.0.0...v1.1.0)

## Release 1.0.0 [2024-06-21]

**Breaking changes**

  - use namespaced Puppet 4.x functions (require stdlib >= 9)

[Full diff](https://github.com/deric/puppet-smartd/compare/v0.5.0...v1.0.0)


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
