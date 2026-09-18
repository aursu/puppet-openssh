# @summary openssh module parameters
#
# Openssh module parameters
#
# @example
#   include openssh::params
class openssh::params {
  if $facts['os']['family'] == 'RedHat' {
    $base_package_name = 'openssh'
    $server_package_name = 'openssh-server'
    $client_package_name = 'openssh-clients'
    $service_name = 'sshd'
    $config_template = 'openssh/sshd_config.redhat.erb'

    $openssh_server_dependencies = undef
    $package_provider = 'dnf'

    # Snapshots of what `update-crypto-policies` renders for the DEFAULT policy
    # on each release, with the SHA-1 MACs and key exchanges removed. They are
    # only rendered when disable_policy asks this module to own the algorithm
    # lists instead of the distribution; see openssh::disable_policy.
    #
    # Taken from /etc/crypto-policies/back-ends/opensshserver.config on 2026-09-18.
    # They date: re-take them when the distribution's policy moves.
    case $facts['os']['release']['major'] {
      '8': {
        $ciphers = [
          'aes256-gcm@openssh.com',
          'chacha20-poly1305@openssh.com',
          'aes256-ctr',
          'aes256-cbc',
          'aes128-gcm@openssh.com',
          'aes128-ctr',
          'aes128-cbc',
        ]
        $macs = [
          'hmac-sha2-256-etm@openssh.com',
          'umac-128-etm@openssh.com',
          'hmac-sha2-512-etm@openssh.com',
          'hmac-sha2-256',
          'umac-128@openssh.com',
          'hmac-sha2-512',
        ]
        $kexalgorithms = [
          'curve25519-sha256',
          'curve25519-sha256@libssh.org',
          'ecdh-sha2-nistp256',
          'ecdh-sha2-nistp384',
          'ecdh-sha2-nistp521',
          'diffie-hellman-group-exchange-sha256',
          'diffie-hellman-group14-sha256',
          'diffie-hellman-group16-sha512',
          'diffie-hellman-group18-sha512',
        ]
        $hostkeyalgorithms = [
          'ecdsa-sha2-nistp256',
          'ecdsa-sha2-nistp256-cert-v01@openssh.com',
          'ecdsa-sha2-nistp384',
          'ecdsa-sha2-nistp384-cert-v01@openssh.com',
          'ecdsa-sha2-nistp521',
          'ecdsa-sha2-nistp521-cert-v01@openssh.com',
          'ssh-ed25519',
          'ssh-ed25519-cert-v01@openssh.com',
          'rsa-sha2-256',
          'rsa-sha2-256-cert-v01@openssh.com',
          'rsa-sha2-512',
          'rsa-sha2-512-cert-v01@openssh.com',
          'ssh-rsa',
          'ssh-rsa-cert-v01@openssh.com',
        ]
      }
      '9': {
        $ciphers = [
          'aes256-gcm@openssh.com',
          'chacha20-poly1305@openssh.com',
          'aes256-ctr',
          'aes128-gcm@openssh.com',
          'aes128-ctr',
        ]
        $macs = [
          'hmac-sha2-256-etm@openssh.com',
          'umac-128-etm@openssh.com',
          'hmac-sha2-512-etm@openssh.com',
          'hmac-sha2-256',
          'umac-128@openssh.com',
          'hmac-sha2-512',
        ]
        $kexalgorithms = [
          'curve25519-sha256',
          'curve25519-sha256@libssh.org',
          'ecdh-sha2-nistp256',
          'ecdh-sha2-nistp384',
          'ecdh-sha2-nistp521',
          'diffie-hellman-group-exchange-sha256',
          'diffie-hellman-group14-sha256',
          'diffie-hellman-group16-sha512',
          'diffie-hellman-group18-sha512',
        ]
        $hostkeyalgorithms = [
          'ecdsa-sha2-nistp256',
          'ecdsa-sha2-nistp256-cert-v01@openssh.com',
          'sk-ecdsa-sha2-nistp256@openssh.com',
          'sk-ecdsa-sha2-nistp256-cert-v01@openssh.com',
          'ecdsa-sha2-nistp384',
          'ecdsa-sha2-nistp384-cert-v01@openssh.com',
          'ecdsa-sha2-nistp521',
          'ecdsa-sha2-nistp521-cert-v01@openssh.com',
          'ssh-ed25519',
          'ssh-ed25519-cert-v01@openssh.com',
          'sk-ssh-ed25519@openssh.com',
          'sk-ssh-ed25519-cert-v01@openssh.com',
          'rsa-sha2-256',
          'rsa-sha2-256-cert-v01@openssh.com',
          'rsa-sha2-512',
          'rsa-sha2-512-cert-v01@openssh.com',
        ]
      }
      '10': {
        $ciphers = [
          'aes256-gcm@openssh.com',
          'chacha20-poly1305@openssh.com',
          'aes256-ctr',
          'aes128-gcm@openssh.com',
          'aes128-ctr',
        ]
        $macs = [
          'hmac-sha2-256-etm@openssh.com',
          'umac-128-etm@openssh.com',
          'hmac-sha2-512-etm@openssh.com',
          'hmac-sha2-256',
          'umac-128@openssh.com',
          'hmac-sha2-512',
        ]
        $kexalgorithms = [
          'mlkem768x25519-sha256',
          'mlkem768nistp256-sha256',
          'mlkem1024nistp384-sha384',
          'curve25519-sha256',
          'curve25519-sha256@libssh.org',
          'ecdh-sha2-nistp256',
          'ecdh-sha2-nistp384',
          'ecdh-sha2-nistp521',
          'diffie-hellman-group-exchange-sha256',
          'diffie-hellman-group14-sha256',
          'diffie-hellman-group16-sha512',
          'diffie-hellman-group18-sha512',
        ]
        $hostkeyalgorithms = [
          'ecdsa-sha2-nistp256',
          'ecdsa-sha2-nistp256-cert-v01@openssh.com',
          'sk-ecdsa-sha2-nistp256@openssh.com',
          'sk-ecdsa-sha2-nistp256-cert-v01@openssh.com',
          'ecdsa-sha2-nistp384',
          'ecdsa-sha2-nistp384-cert-v01@openssh.com',
          'ecdsa-sha2-nistp521',
          'ecdsa-sha2-nistp521-cert-v01@openssh.com',
          'ssh-ed25519',
          'ssh-ed25519-cert-v01@openssh.com',
          'sk-ssh-ed25519@openssh.com',
          'sk-ssh-ed25519-cert-v01@openssh.com',
          'rsa-sha2-256',
          'rsa-sha2-256-cert-v01@openssh.com',
          'rsa-sha2-512',
          'rsa-sha2-512-cert-v01@openssh.com',
        ]
      }
      default: {
        $ciphers = [
          'aes256-gcm@openssh.com',
          'chacha20-poly1305@openssh.com',
          'aes256-ctr',
          'aes128-gcm@openssh.com',
          'aes128-ctr',
        ]
        $macs = [
          'hmac-sha2-256-etm@openssh.com',
          'umac-128-etm@openssh.com',
          'hmac-sha2-512-etm@openssh.com',
          'hmac-sha2-256',
          'umac-128@openssh.com',
          'hmac-sha2-512',
        ]
        $kexalgorithms = [
          'curve25519-sha256',
          'curve25519-sha256@libssh.org',
          'ecdh-sha2-nistp256',
          'ecdh-sha2-nistp384',
          'ecdh-sha2-nistp521',
          'diffie-hellman-group-exchange-sha256',
          'diffie-hellman-group14-sha256',
          'diffie-hellman-group16-sha512',
          'diffie-hellman-group18-sha512',
        ]
        $hostkeyalgorithms = [
          'ecdsa-sha2-nistp256',
          'ecdsa-sha2-nistp256-cert-v01@openssh.com',
          'sk-ecdsa-sha2-nistp256@openssh.com',
          'sk-ecdsa-sha2-nistp256-cert-v01@openssh.com',
          'ecdsa-sha2-nistp384',
          'ecdsa-sha2-nistp384-cert-v01@openssh.com',
          'ecdsa-sha2-nistp521',
          'ecdsa-sha2-nistp521-cert-v01@openssh.com',
          'ssh-ed25519',
          'ssh-ed25519-cert-v01@openssh.com',
          'sk-ssh-ed25519@openssh.com',
          'sk-ssh-ed25519-cert-v01@openssh.com',
          'rsa-sha2-256',
          'rsa-sha2-256-cert-v01@openssh.com',
          'rsa-sha2-512',
          'rsa-sha2-512-cert-v01@openssh.com',
        ]
      }
    }
  }
  elsif $facts['os']['name'] == 'Ubuntu' {
    $base_package_name = 'ssh'
    $server_package_name = 'openssh-server'
    $client_package_name = 'openssh-client'
    $package_provider = undef
    $service_name = 'ssh'
    $config_template = 'openssh/sshd_config.ubuntu.erb'

    $openssh_server_dependencies = undef
    $ciphers = [
      'chacha20-poly1305@openssh.com',
      'aes128-ctr',
      'aes192-ctr',
      'aes256-ctr',
      'aes128-gcm@openssh.com',
      'aes256-gcm@openssh.com',
    ]
    $macs = [
      'umac-64-etm@openssh.com',
      'umac-128-etm@openssh.com',
      'hmac-sha2-256-etm@openssh.com',
      'hmac-sha2-512-etm@openssh.com',
      'hmac-sha1-etm@openssh.com',
      'umac-64@openssh.com',
      'umac-128@openssh.com',
      'hmac-sha2-256',
      'hmac-sha2-512',
      'hmac-sha1',
    ]
    $kexalgorithms = [
      'curve25519-sha256',
      'curve25519-sha256@libssh.org',
      'ecdh-sha2-nistp256',
      'ecdh-sha2-nistp384',
      'ecdh-sha2-nistp521',
      'diffie-hellman-group-exchange-sha256',
      'diffie-hellman-group14-sha1',
    ]
  }
  else {
    $base_package_name = 'openssh'
    $package_provider = undef
    # if not RedHat or Ubuntu - no support
    $server_package_name = undef
    $client_package_name = undef
    $openssh_server_dependencies = undef
    $ciphers = undef
    $macs = undef
    $kexalgorithms = undef
    $service_name = 'sshd'
    $config_template = undef
  }

  # sshd(8) reads configuration data from /etc/ssh/sshd_config (or the file
  # specified with -f on the command line)
  $config          = '/etc/ssh/sshd_config'
  $ssh_port        = 22

  # Drop-in directory pulled in by the Include at the top of sshd_config.
  $config_dir      = '/etc/ssh/sshd_config.d'

  # Whether sshd on this platform reads the drop-in directory at all. RHEL grew
  # the Include in release 9; on 8 the directory does not exist and the crypto
  # policy arrives through /etc/sysconfig/sshd instead.
  $config_dir_supported = $facts['os']['family'] ? {
    'Debian' => true,
    'RedHat' => versioncmp($facts['os']['release']['major'], '9') >= 0,
    default  => false,
  }

  # Whether the directory's contents are this module's to manage, and so to
  # purge. On Debian it is where site configuration and cloud images drop their
  # files, and an unmanaged one overrides everything below the Include. On
  # RedHat the distribution owns it - 40-redhat-crypto-policies.conf carries the
  # system-wide crypto policy and 50-redhat.conf the distribution's defaults -
  # so it is left alone.
  $manage_config_dir = $facts['os']['family'] ? {
    'Debian' => true,
    default  => false,
  }

  # Socket unit to refresh when SSH is socket-activated. Only a fallback: the
  # ssh_socket_unit fact reports the unit that is actually active and is
  # preferred, because it reflects the host rather than an assumption about
  # it. This value is used when manage_socket is forced true on a host where
  # the fact found nothing - a first run, before the package is installed.
  if $facts['os']['family'] == 'Debian' {
    $socket_name = 'ssh.socket'
  }
  else {
    $socket_name = 'sshd.socket'
  }
}
