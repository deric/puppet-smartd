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
# @param options
#     Arguments passed to devicescan devices
#
# @param defaults
#     Common arguments for all devices
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
  Smartd::Config          $options = undef,
  Smartd::Config          $defaults = undef,
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
        'defaults'   => $defaults,
        'devices'    => smartd::apply_rules($disks, $rules),
        'devicescan' => $devicescan,
        'options'    => $options,
    }),
    require => Package[$package_name],
  }
}
