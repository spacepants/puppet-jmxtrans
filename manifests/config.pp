# @private
#
# This class is used to configure the jmxtrans config files
#
class jmxtrans::config {
  include ::jmxtrans

  if $::jmxtrans::manage_service_file {
    case $facts['service_provider'] {
      'systemd': {
        file { '/etc/systemd/system/jmxtrans.service':
          ensure  => file,
          owner   => 'root',
          group   => 'root',
          mode    => '0444',
          content => epp($::jmxtrans::systemd_template, { 'user' => $::jmxtrans::user }),
        }
        ~>
        exec { 'jmxtrans systemctl daemon-reload':
          command     => 'systemctl daemon-reload',
          refreshonly => true,
          path        => $facts['path'],
        }
      }
      default: {
        file { '/etc/init.d/jmxtrans':
          ensure  => file,
          owner   => 'root',
          group   => 'root',
          mode    => '0755',
          content => epp('jmxtrans/jmxtrans.init.epp', { 'user' => $::jmxtrans::user }),
        }
      }
    }
  }
}
