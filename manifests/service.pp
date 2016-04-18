# == Class jmxtrans::service
#
# This class is meant to be called from jmxtrans.
# It ensure the service is running.
#
class jmxtrans::service {

  service { $::jmxtrans::service_name:
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }
}
