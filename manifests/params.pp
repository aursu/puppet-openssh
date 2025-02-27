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

    if $facts['os']['release']['major'] == '7' {
      $openssh_server_dependencies = ['initscripts']
    }
    else {
      $openssh_server_dependencies = undef
    }

    if $facts['os']['release']['major'] in ['6', '7'] {
      $package_provider = 'yum'
    }
    else {
      $package_provider = 'dnf'
    }

    case $facts['os']['release']['major'] {
      '6': {
        $ciphers = [
          'aes256-ctr',
          'aes192-ctr',
          'aes128-ctr',
        ]
        $macs = [
          'hmac-sha2-512',
          'hmac-sha2-256',
        ]
        $kexalgorithms = [
          'diffie-hellman-group-exchange-sha256',
        ]
      }
      default: {
        $ciphers = [
          'chacha20-poly1305@openssh.com',
          'aes256-gcm@openssh.com',
          'aes128-gcm@openssh.com',
          'aes256-ctr',
          'aes192-ctr',
          'aes128-ctr',
        ]
        $macs = [
          'hmac-sha2-512-etm@openssh.com',
          'hmac-sha2-256-etm@openssh.com',
          'umac-128-etm@openssh.com',
          'hmac-sha2-512',
          'hmac-sha2-256',
          'umac-128@openssh.com',
        ]
        $kexalgorithms = [
          'curve25519-sha256@libssh.org',
          'ecdh-sha2-nistp521',
          'ecdh-sha2-nistp384',
          'ecdh-sha2-nistp256',
          'diffie-hellman-group-exchange-sha256',
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
}
