# puppet-smartd

[![Puppet
Forge](http://img.shields.io/puppetforge/v/deric/smartd.svg)](https://forge.puppet.com/modules/deric/smartd) [![Build Status](https://github.com/deric/puppet-smartd/actions/workflows/spec.yml/badge.svg?branch=main)](https://github.com/deric/puppet-smartd/actions/workflows/spec.yml)

Simplified `smartd` configuration management with Puppet.

## Usage

```puppet
include smartd
```
and confgure e-mail nofifications for all disks:
```yaml
smartd::defaults: '-a -m root@domain.org'
```
this would generate a `smartd.conf` based on `smartd::disks` (by default `$facts['disks']` is used):
```
DEFAULT -a -m root@domain.org
/dev/sda -d ata
/dev/sdb -d ata
```

Main class `smartd` supports following attributes:

 - `defaults` Shared configuration directives can be specified e.g. common email `-m root@my.org`. Accepts string or an array or strings.
 - `disks` Fact or Hash containing devices declaration
 - `rules` Applied `smartd` options to disks definition.
 - `devicescan` When enabled will automatically detect all matching devices (restricted by `options`). Default: `false`
 - `options` DEVICESCAN options, e.g. `-d removable` will ignore errors on removable devices. Requires `devicescan: true`. Accepts string or an array or strings.

By default Puppet built-in `$facts['disks']` is used (accessible also via `facter -y disks`), e.g.:

```yaml
nvme0n1:
  model: "SAMSUNG MZQL2960HCJR-00A07"
  serial: "S64FNE0R503522"
  size: 894.25 GiB
  size_bytes: 960197124096
  type: ssd
```
that can be used to generate configuration (at least simple list of devices). Though any other fact or hardcoded hash of disks might be used.

The `rules` parameter can be used to define e.g. model/vendor specific rules that might be generalized.

```yaml
smartd::rules:
  - attr: model         # attr value match disk attributes, e.g. vendor, type, etc. might be used
    match: SAMSUNG MZ7
    options: -I 173     # ignore wear_level_count for disks matching this model
```

Match device name using special key `$name`:

```yaml
smartd::rules:
  - attr: $name
    match: ^nvme  # regexp match
    options: -H   # will append all matching rules
  - attr: type
    match: ssd
    options:  -l error
```
this would output (assuming NVMe has attribute type with value `ssd`)
```
/dev/nvme0n1 -H -l error
```

Ignore device completely (will be ommited from the list):

```yaml
smartd::rules:
  - attr: vendor
    match: DELL
    action: ignore
```

Apply `megaraid` device type
```yaml
smartd::rules:
  - atrr: model
    match: PERC
    options: -d megaraid,0
```

## Configuration parameters

See [man smartd.conf](https://linux.die.net/man/5/smartd.conf) for full configuration specification.

  * `-a` equivalent of `-H -f -t -l error -l selftest -l selfteststs -C 197 -U 198`
  * `-m` email address for notifications
  * `-d` device type `auto`,`ata`, `scsi`,`nvme`,`ignore`,`removable`
  * `-H` perform S.M.A.R.T health check, i.e. `smartctl -H /dev/sda`
  * `-i` ignore failure of Usage Attributes (e.g. percent of lifetime used)

## Examples

Will scan for all devices, and then monitor them. It will send one email warning per device for any problems that are found.
```yaml
smartd::devicescan: true
smartd::options: '-H -d ata -m root@example.com'
```
this would produce config:

```
DEVICESCAN -H -d ata -m root@example.com
```
that will ensure that `smartd` will check SMART health status on all `ata` drives daily.

Common configuration will be applied for all disks defined bellow (in the config).
```yaml
smartd::defaults:
  - '-a -R5! -W 2,40,45 -I 194 -s L/../../7/00'
  - '-m admin@example.com'
```

## Limitations

Written for Puppet 6 and newer, backward compatibility with older versions hasn't been tested.
