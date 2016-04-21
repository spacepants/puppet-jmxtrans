# @private
#
# This class manages the jmxtrans service. If `$::jmxtrans::service_name` is
# undef, this class does nothing.
#
class jmxtrans::service {
  include ::jmxtrans

  if $::jmxtrans::service_name {
    service { $::jmxtrans::service_name:
      ensure     => running,
      hasstatus  => true,
      hasrestart => true,
    }
  }
}
