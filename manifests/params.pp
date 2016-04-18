# == Class jmxtrans::params
#
# This class is meant to be called from jmxtrans.
# It sets variables according to platform.
#
class jmxtrans::params {
  case $::osfamily {
    'Debian': {
      $package_name = 'jmxtrans'
      $service_name = 'jmxtrans'
    }
    'RedHat', 'Amazon': {
      $package_name = 'jmxtrans'
      $service_name = 'jmxtrans'
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }
}
