# puppet-smartd

Simplified `smartd` configuration management with Puppet.

## Usage

```puppet
include smartd
```

Main class `smartd` supports following attributes:

 - `devicescan` When enabled will automatically detect all matching devices (restricted by `options`). Default: `false`
 - `options` DEVICESCAN options, e.g. `-d removable` will ignore errors on removable devices. Requires `devicescan: true`. Accepts string or an array or strings.
 - `defaults` Shared configuration directives can be specified e.g. common email `-m root@my.org`. Accepts string or an array or strings.

## Configuration parameters

See [man smartd.conf](https://linux.die.net/man/5/smartd.conf) for full configuration specification.

  * `-m` email address for notifications
  * `-d` device type `ata`, `scsi`
  * `-H` perform S.M.A.R.T health check, i.e. `smartctl -H /dev/sda`

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