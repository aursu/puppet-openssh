# Manage SSHd daemon service
#
# @summary Manage SSHd daemon service
#
# @example
#   include openssh::service
class openssh::service (
  Boolean $service_enabled  = true,
  String  $service_ensure   = running,
  String  $service_name     = $openssh::params::service_name,
) inherits openssh::params {
  service { $service_name:
    ensure     => $service_ensure,
    hasstatus  => true,
    hasrestart => true,
    enable     => $service_enabled,
  }

  if  $facts['os']['family'] == 'RedHat' and
  $facts['os']['release']['major'] in ['7', '8'] {
    systemd::dropin_file { 'sshd.service.d/override.conf':
      filename => 'override.conf',
      unit     => 'sshd.service',
      content  => template('openssh/systemd.override.conf.erb'),
      before   => Service[$service_name],
    }
  }
}
