# @summary Manage smartd daemon configuration
#
# Generate rules for S.M.A.R.T attributes monitoring
#
# @param disks
#     Hash with devices (device name => {attributes})
#
# @param rules
#     An array of Hashes containing rules for assiging flags
#
# @param package_name
#     Smartmontools package name
#
# @param package_ensure
#     Standard Puppet's package ensure, valid values e.g. 'present','latest','absent','purged'
#     Default: present
#
# @param manage_package
#     Whether Smartmontools package should be managed by this module
#
# @param manage_service
#     Whether smartd service should be managed
#
# @param config_file
#     Path to main smartd config file
#
# @param service_name
#     smart daemon service name
#
# @param service_ensure
#     Service state, either 'running' or 'stopped'
#     Default: 'running'
#
# @param devicescan
#     Whether enable automatic disk detection.
#     Default: false
#
# @param self_check
#     Whether enable automatic self-health checks running regularly.
#
# @param randomize_check_hour
#     Whether the daily and weekly check hours should be randomized within the
#     range from 0 up to the configured `check_daily_hour`/`check_weekly_hour`.
#
# @param check_daily_hour
#     Upper interval for the randomized daily run hour
#
# @param check_weekly_hour
#     Upper interval for the randomized weekly run hour
#
# @param options
#     Arguments passed to devicescan devices
#
# @param defaults
#     Common arguments for all devices
#
# @param package_options
#     Install options passed to package installer
#
# @example
#   include smartd
class smartd (
  String                  $service_name,
  Stdlib::Absolutepath    $config_file,
  String                  $package_name,
  String                  $package_ensure = 'present',
  Hash                    $disks = pick($facts['disks'], {}),
  Array[Hash]             $rules = [],
  Boolean                 $manage_package = true,
  Boolean                 $manage_service = true,
  Stdlib::Ensure::Service $service_ensure = 'running',
  Boolean                 $devicescan = false,
  Boolean                 $self_check = false,
  Boolean                 $randomize_check_hour = true,
  Integer[0, 23]          $check_daily_hour = 6,
  Integer[0, 23]          $check_weekly_hour = 6,
  Smartd::Config          $options = undef,
  Smartd::Config          $defaults = undef,
  Optional[Array]         $package_options = undef,
) {
  if $manage_package {
    ensure_resource('package', [$package_name], {
        ensure => $package_ensure,
        install_options => $package_options,
      }
    )
  }

  if $manage_service {
    service { $service_name:
      ensure     => $service_ensure,
      enable     => true,
      hasrestart => true,
      hasstatus  => true,
      subscribe  => File[$config_file],
    }

    Package[$package_name] -> Service[$service_name]
  }

  $_defaults = if $self_check {
    # -o on: enable automatic offline actions
    # -S on: enable SMART scheduling state
    # -s (S/...|L/...): S => short self-test daily at 02:00; L => long self-test weekly (Sat) at 03:00
    # - '-o on -S on -s (S/../.././02|L/../../6/03)'
    if $randomize_check_hour {
      $daily = sprintf('%02d', fqdn_rand($check_daily_hour, 'S.M.A.R.T. daily'))
      $weekly = sprintf('%02d',fqdn_rand($check_weekly_hour, 'S.M.A.R.T. weekly'))
    } else {
      $daily = sprintf('%02d', $check_daily_hour)
      $weekly = sprintf('%02d',$check_weekly_hour)
    }

    $disk_check = "-o on -S on -s (S/../.././${daily}|L/../../6/${weekly})"
    if $defaults {
      if $defaults =~ Array {
        $defaults + [$disk_check]
      } else {
        [$defaults, $disk_check]
      }
    } else {
      [$disk_check]
    }
  } else {
    $defaults
  }

  file { $config_file:
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp("${module_name}/smartd.conf.epp", {
        'defaults'   => $_defaults,
        'devices'    => smartd::apply_rules($disks, $rules),
        'devicescan' => $devicescan,
        'options'    => $options,
    }),
    require => Package[$package_name],
  }
}
