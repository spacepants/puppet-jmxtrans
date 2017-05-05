# This is the main class for using jmxtrans. It should be included before using
# anything else from the module.
#
# @example jmxtrans is installed via some other method
#    include jmxtrans
#
# @example jmxtrans is available in a repository via the package `jmxtrans`
#    class { 'jmxtrans':
#      package_name => 'jmxtrans',
#      service_name => 'jmxtrans',
#    }
#
# @example jmxtrans should be installed via rpm installing a remote package
#    class { 'jmxtrans':
#      package_name  => 'jmxtrans',
#      service_name  => 'jmxtrans',
#      package_source => 'http://central.maven.org/maven2/org/jmxtrans/jmxtrans/254/jmxtrans-254.rpm',
#    }
#
# @example jmxtrans runs under a different user with a different config path
#    class { 'jmxtrans':
#      config_directory => '/etc/jmxtrans/config/',
#      user             => 'java',
#    }
#
# @param package_name [String] (optional) The package to install. Skips managing the package if undef.
#
# @param service_name [String] (optional) The service to manage. Skips managing the service if undef.
#
# @param package_source [String] (optional) A URL or local path to get a package from.
#
# @param package_provider [String] (optional) Used to explicitly set the provider to use to install the package.
#
# @param working_directory [String] (optional) Sets the working directory for the jmxtrans processes.
#
# @param systemd_environment_file [String] (optional) Path to the file where the environment variables needed by
# the jmxtrans service should be defined (e.g. '/etc/default/jmxtrans' or '/etc/sysconfig/jmxtrans').
#
# @param package_version [String] The version of the package to be installed. Defaults to 'present'.
#
# @param systemd_template [String] Template to be be used to generate the systemd unit. Defaults to 'jmxtrans/jmxtrans.service.pp'
#
# @param binary_path [String] Path to the jmxtrans executable. Defaults to '/usr/share/jmxtrans/bin/jmxtrans'.
#
# @param config_directory [String] Where to place JSON configurations. Defaults to '/var/lib/jmxtrans'.
#
# @param user [String] The user who will own the JSON configurations. Defaults to 'jmxtrans'.
#
class jmxtrans (
  Optional[String[1]] $package_name = undef,
  Optional[String[1]] $service_name = undef,
  Optional[String[1]] $package_source = undef,
  Optional[String[1]] $package_provider = undef,
  Optional[String[1]] $working_directory = undef,
  Optional[String[1]] $systemd_environment_file = undef,
  Boolean $manage_service_file = false,
  String[1] $package_version = present,
  String[1] $systemd_template = 'jmxtrans/jmxtrans.service.epp',
  String[1] $binary_path = '/usr/share/jmxtrans/bin/jmxtrans',
  String[1] $config_directory = '/var/lib/jmxtrans',
  String[1] $user = 'jmxtrans',
) {
  contain ::jmxtrans::config
  contain ::jmxtrans::install
  contain ::jmxtrans::service

  Class['::jmxtrans::install'] -> Class['::jmxtrans::config']
  Class['::jmxtrans::config']  ~> Class['::jmxtrans::service']
  Class['::jmxtrans::install'] ~> Class['::jmxtrans::service']
}
