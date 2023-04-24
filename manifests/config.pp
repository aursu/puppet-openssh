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
class openssh::config (
  Stdlib::Unixpath $config = $openssh::config,
  Stdlib::Port $ssh_port = $openssh::ssh_port,
  Optional[Integer[1,2]] $protocol = $openssh::protocol,
  String $config_template = $openssh::config_template,
  Variant[Enum['none'], Stdlib::Unixpath] $banner = $openssh::banner,
  Optional[String] $keys_file = $openssh::keys_file,
  Enum['yes', 'no', 'all', 'local', 'remote']
  $allow_tcp_forwarding = $openssh::allow_tcp_forwarding,
  Enum['yes', 'no', 'without-password', 'prohibit-password', 'forced-commands-only']
  $permit_root_login = $openssh::permit_root_login,
  Enum['yes', 'no'] $strict_modes = $openssh::strict_modes,
  Enum['yes', 'no'] $gss_api_authentication = $openssh::gss_api_authentication,
  Enum['yes', 'no'] $hostbased_authentication = $openssh::hostbased_authentication,
  Openssh::Switch $challenge_response_authentication = $openssh::challenge_response_authentication,
  Openssh::Switch $password_authentication = $openssh::password_authentication,
  Optional[Enum['yes', 'no', 'sandbox']]
  $use_privilege_separation = $openssh::use_privilege_separation,
  Enum['yes', 'point-to-point', 'ethernet', 'no']
  $permit_tunnel = $openssh::permit_tunnel,
  Optional[Variant[String, Array[Openssh::MACs]]] $macs = $openssh::macs,
  Optional[Variant[String, Array[Openssh::Ciphers]]] $ciphers = $openssh::ciphers,
  Optional[Variant[String, Array[Openssh::KexAlgorithms]]] $kexalgorithms = $openssh::kexalgorithms,
  # whether to add HostKey directives into sshd_config or not
  Boolean $setup_host_key = $openssh::setup_host_key,
  Boolean $setup_ed25519_key = $openssh::setup_ed25519_key,
) {
  if $facts['os']['name'] in ['RedHat', 'CentOS'] and $facts['os']['release']['major'] in ['5', '6'] {
    $ed25519_key_generate = false
  }
  else {
    $ed25519_key_generate = $setup_ed25519_key
  }

  file { $config:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => template($config_template),
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
