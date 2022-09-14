# @summary Manage smartd daemon configuration
#
# Generate rules for S.M.A.R.T attributes monitoring
#
#
# @param mailto
#     E-mail address for notifications, multilple email addresses can be separated by comma
#
# @param disks
#     Hash
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
# @param options
#
#
# @example
#   include smartd
class smartd (
  String                  $service_name,
  Stdlib::Absolutepath    $config_file,
  String                  $package_name,
  Optional[String]        $mailto = undef,
  String                  $package_ensure = 'present',
  Hash                    $disks = pick($facts['disks'], {}),
  Hash                    $rules = {},
  Boolean                 $manage_package = true,
  Boolean                 $manage_service = true,
  Stdlib::Ensure::Service $service_ensure = 'running',
  Boolean                 $devicescan = false,
  Array[String]           $options = [],
  Array[String]           $defaults = [],
) {
  if $manage_package {
    ensure_packages([$package_name], { ensure => $package_ensure })
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

  file { $config_file:
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp("${module_name}/smartd.conf.epp", {
      'disks'      => $disks,
      'devicescan' => $devicescan,
      'options'    => $options,
      'defaults'   => $defaults,
    }),
    require => Package[$package_name],
  }
}
