# Manage SSHd daemon service
#
# @summary Manage SSHd daemon service
#
# @param service_enabled
#   Whether the SSH service is enabled at boot.
#
# @param service_ensure
#   Desired state of the SSH service.
#
# @param service_name
#   Name of the SSH service unit.
#
# @param manage_socket
#   Whether to restart the systemd socket unit when sshd_config changes.
#
#   It matters because listen_address does nothing without it. Where SSH is
#   socket-activated, sshd does not perform the bind - systemd does, using
#   addresses that sshd-socket-generator derives from sshd_config. The
#   generator re-runs on `systemctl daemon-reload`, and the socket has to be
#   restarted afterwards to bind what it produced. Reload the service alone
#   and the old socket stays bound while the configuration reads as applied.
#
#   The generator is the distribution's own mechanism and stays the source of
#   truth; nothing here writes a competing drop-in.
#
#   Left true everywhere because it costs nothing where it does not apply: the
#   restart is guarded by `systemctl is-enabled`, which fails on a host that
#   does not use socket activation.
#
# @param socket_name
#   Socket unit to restart.
#
# @example
#   include openssh::service
class openssh::service (
  Boolean $service_enabled  = true,
  String  $service_ensure   = running,
  String  $service_name     = $openssh::params::service_name,
  Boolean $manage_socket    = true,
  String[1] $socket_name    = $openssh::params::socket_name,
) inherits openssh::params {
  service { $service_name:
    ensure     => $service_ensure,
    hasstatus  => true,
    hasrestart => true,
    enable     => $service_enabled,
  }

  if  $facts['os']['family'] == 'RedHat' and
  $facts['os']['release']['major'] == '8' {
    systemd::dropin_file { 'sshd.service.d/override.conf':
      filename => 'override.conf',
      unit     => 'sshd.service',
      content  => template('openssh/systemd.override.conf.erb'),
      before   => Service[$service_name],
    }
  }

  if $manage_socket {
    # openssh::config notifies the reload, which in turn notifies this. Two
    # steps rather than one command, because they are two different things:
    # the reload re-runs the generator, and only the restart binds what it
    # wrote.
    include bsys::systemctl::daemon_reload

    # 1b7dac3 is sha256('openssh::service')[0,7], matching the convention
    # bsys::systemctl::daemon_reload uses for its own title. "restart
    # ssh.socket" is the name another module would reasonably pick for the
    # same unit, and the second one to do so would be a duplicate
    # declaration; the digest makes the title this class's own.
    #
    # Written out rather than computed: the input is a literal, so the result
    # never varies and there is nothing to work out at catalogue time.
    $socket_exec = "restart-${socket_name}-1b7dac3"

    # Guarded at apply time rather than by a fact. `is-enabled` answers on the
    # host, after the package resource has run, so a first run on a new host
    # is already correct - there is no compile-time guess to be wrong about,
    # and nothing to converge on a second run.
    exec { $socket_exec:
      command     => "systemctl restart ${socket_name}",
      onlyif      => "systemctl is-enabled ${socket_name}",
      path        => '/bin:/sbin:/usr/bin:/usr/sbin',
      refreshonly => true,
    }

    Class['bsys::systemctl::daemon_reload'] ~> Exec[$socket_exec]
  }
}
