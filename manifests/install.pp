# @private
#
# This class is used to install the jmxtrans package. If
# `$::jmxtrans::package_name` is undef, then this class will do nothing. If
# `$::jmxtrans::package_source` is set, the package will be installed from the
# location specified.
#
# This class will use the default provider for a platform if an explicit
# value is not set for `$::jmxtrans::package_source`. If a value is set for
# that parameter, this class will use the `rpm` provider on RedHat systems and
# the `dpkg` provider on Debian systems. This can be overridden by specifying a
# value for the `$::jmxtrans::package_provider` parameter.
#
class jmxtrans::install {
  include ::jmxtrans

  if $::jmxtrans::package_name {
    if $::jmxtrans::package_provider {
      $provider = $::jmxtrans::package_provider
    } elsif $::jmxtrans::package_source {
      $provider = $facts['os']['family'] ? {
        'RedHat' => 'rpm',
        'Debian' => 'dpkg',
        default  => undef
      }
    } else {
      $provider = undef
    }

    package { $::jmxtrans::package_name:
      ensure          => $::jmxtrans::package_version,
      provider        => $provider,
      source          => $::jmxtrans::package_source,
      install_options => $::jmxtrans::package_options,
    }
  }

}
