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
# @param config_directory [String] Where to place JSON configurations. Defaults to '/var/lib/jmxtrans'.
#
# @param user [String] The user who will own the JSON configurations. Defaults to 'jmxtrans'.
#
class jmxtrans (
  Optional[String[1]] $package_name = undef,
  Optional[String[1]] $service_name = undef,
  Optional[String[1]] $package_source = undef,
  Optional[String[1]] $package_provider = undef,
  Boolean $manage_service_file = false,
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
