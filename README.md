# puppet-smartd

Simplified `smartd` configuration management with Puppet.

## Usage

```puppet
include smartd
```

You might want to modify email for notifications:

```yaml
smartd::mailto: root,foo@bar.com
```

## Configuration

See [man smartd.conf](https://linux.die.net/man/5/smartd.conf) for full configuration specification.

## Limitations

Written for Puppet 6 and newer, backward compatibility with older versions hasn't been tested.