# Class: jmxtrans
# ===========================
#
# Full description of class jmxtrans here.
#
# Parameters
# ----------
#
# * `sample parameter`
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
class jmxtrans (
  $package_name = $::jmxtrans::params::package_name,
  $service_name = $::jmxtrans::params::service_name,
) inherits ::jmxtrans::params {

  # validate parameters here

  class { '::jmxtrans::install': } ->
  class { '::jmxtrans::config': } ~>
  class { '::jmxtrans::service': } ->
  Class['::jmxtrans']
}
