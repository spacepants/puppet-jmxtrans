# == Class jmxtrans::install
#
# This class is called from jmxtrans for install.
#
class jmxtrans::install {

  package { $::jmxtrans::package_name:
    ensure => present,
  }
}
