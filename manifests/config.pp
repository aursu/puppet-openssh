# @summary Setup SSHD daemon configuration
#
# Setup SSHD daemon configuration based on template
#
# @example
#   include openssh::config
#
# @param setup_ed25519_key
#   Whether to generate ed25519 ssh key by default (if absent) or not
#
# @param hostkeyalgorithms
#   Specifies the host key signature algorithms that the server offers.
#   The defaults (OpenSSH 7.3) are: ecdsa-sha2-nistp256-cert-v01@openssh.com,
#   ecdsa-sha2-nistp384-cert-v01@openssh.com, ecdsa-sha2-nistp521-cert-v01@openssh.com,
#   ssh-ed25519-cert-v01@openssh.com, ssh-rsa-cert-v01@openssh.com,
#   ssh-dss-cert-v01@openssh.com, ecdsa-sha2-nistp256, ecdsa-sha2-nistp384,
#   ecdsa-sha2-nistp521, ssh-ed25519, ssh-rsa, ssh-dss.
#
class openssh::config (
  Stdlib::Unixpath $config = $openssh::config,
  Stdlib::Port $ssh_port = $openssh::ssh_port,
  Optional[String] $config_template = $openssh::config_template,
  Variant[Enum['none'], Stdlib::Unixpath] $banner = $openssh::banner,
  Optional[String] $keys_file = $openssh::keys_file,
  Enum['yes', 'no', 'all', 'local', 'remote']
  $allow_tcp_forwarding = $openssh::allow_tcp_forwarding,
  Enum['yes', 'no', 'without-password', 'prohibit-password', 'forced-commands-only']
  $permit_root_login = $openssh::permit_root_login,
  Enum['yes', 'no'] $strict_modes = $openssh::strict_modes,
  Enum['yes', 'no'] $gss_api_authentication = $openssh::gss_api_authentication,
  Enum['yes', 'no'] $hostbased_authentication = $openssh::hostbased_authentication,
  Openssh::Switch $password_authentication = $openssh::password_authentication,
  Enum['yes', 'point-to-point', 'ethernet', 'no']
  $permit_tunnel = $openssh::permit_tunnel,
  Optional[Variant[String, Array[Openssh::MACs]]] $macs = $openssh::macs,
  Optional[Variant[String, Array[Openssh::Ciphers]]] $ciphers = $openssh::ciphers,
  Optional[Variant[String, Array[Openssh::KexAlgorithms]]] $kexalgorithms = $openssh::kexalgorithms,
  Optional[Variant[String, Array[Openssh::HostKeyAlgorithms]]] $hostkeyalgorithms = $openssh::hostkeyalgorithms,
  Optional[Tuple[Integer[0], Integer[0, 100], Integer[0]]] $max_startups = $openssh::max_startups,
  Integer[1] $max_sessions = $openssh::max_sessions,
  Openssh::Switch $use_dns = $openssh::use_dns,
  Optional[Array[Stdlib::IP::Address::Nosubnet, 1]] $listen_address = $openssh::listen_address,
  Stdlib::Absolutepath $config_dir = $openssh::config_dir,
  Boolean $manage_config_dir = $openssh::manage_config_dir,
  Boolean $purge_config_dir = $openssh::purge_config_dir,
  # whether to add HostKey directives into sshd_config or not
  Boolean $setup_host_key = $openssh::setup_host_key,
  Boolean $setup_ed25519_key = $openssh::setup_ed25519_key,
) {
  if $max_startups {
    if $max_startups[2] < $max_startups[0] {
      fail("MaxStartups: 'full' value (${max_startups[2]}) must be >= 'start' value (${max_startups[0]})")
    }
  }

  $ed25519_key_generate = $setup_ed25519_key

  if $config_template {
    file { $config:
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0640',
      content => template($config_template),
    }
  }
  else {
    file { $config:
      ensure => file,
      owner  => 'root',
      group  => 'root',
      mode   => '0640',
    }
  }

  # The drop-in directory the Include at the top of sshd_config pulls in.
  #
  # Managed by default only where the rendered configuration actually reads
  # it - see openssh::params::config_include. Purged by default there, and
  # the reason is the Include's position: sshd honours the FIRST occurrence
  # of a keyword, so a file here does not supplement the settings written
  # below it, it overrides them. An unmanaged drop-in turns this module's
  # configuration into a suggestion while leaving it looking applied - the
  # file says one thing and `sshd -T` reports another.
  #
  # recurse is required for purge to do anything; without it the parameter is
  # silently inert.
  if $manage_config_dir {
    file { $config_dir:
      ensure  => directory,
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      recurse => $purge_config_dir,
      purge   => $purge_config_dir,
    }
  }

  # Any change to sshd_config reloads the systemd manager, which re-runs
  # sshd-socket-generator. On a socket-activated host that generator is what
  # turns ListenAddress into the addresses systemd binds, so without the
  # reload the file changes and the listener does not.
  #
  # Notified on every change rather than on ListenAddress alone: the generator
  # reads Port as well, and the reload is cheap and harmless where nothing is
  # socket-activated. openssh::service restarts the socket afterwards.
  include bsys::systemctl::daemon_reload
  File[$config] ~> Class['bsys::systemctl::daemon_reload']

  # Removing a drop-in changes the effective configuration exactly as editing
  # sshd_config does, so a purge has to reach the same reload and restart.
  if $manage_config_dir and $purge_config_dir {
    File[$config_dir] ~> Class['bsys::systemctl::daemon_reload']
  }

  if $setup_host_key {
    # https://access.redhat.com/solutions/1486393
    exec {
      default:
        path => '/bin:/usr/bin',
        ;
      'ssh-keygen -t rsa -P "" -f /etc/ssh/ssh_host_rsa_key':
        creates => '/etc/ssh/ssh_host_rsa_key',
        ;
      'ssh-keygen -t ecdsa -P "" -f /etc/ssh/ssh_host_ecdsa_key':
        creates => '/etc/ssh/ssh_host_ecdsa_key',
        ;
    }

    if $ed25519_key_generate {
      exec { 'ssh-keygen -t ed25519 -P "" -f /etc/ssh/ssh_host_ed25519_key':
        creates => '/etc/ssh/ssh_host_ed25519_key',
        path    => '/bin:/usr/bin',
      }
    }
  }
}
