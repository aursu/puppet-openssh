# @summary openssh module parameters
#
# Openssh module parameters
#
# @example
#   include openssh::params
class openssh::params {
  $base_package_name = 'openssh'

  if $facts['os']['name'] in ['RedHat', 'CentOS'] {
    $server_package_name = 'openssh-server'
    $client_package_name = 'openssh-clients'
    if $facts['os']['release']['major'] in ['7', '8'] {
      $openssh_server_dependencies = ['initscripts']
    }
    else {
      $openssh_server_dependencies = undef
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
          'aes128-ctr'
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
  else {
    # if not RedHat - no support
    $server_package_name = undef
    $client_package_name = undef
    $openssh_server_dependencies = undef
    $ciphers = undef
    $macs = undef
    $kexalgorithms = undef
  }

  $service_name    = 'sshd'
  # sshd(8) reads configuration data from /etc/ssh/sshd_config (or the file
  # specified with -f on the command line)
  $config          = '/etc/ssh/sshd_config'
  $ssh_port        = 22


}
