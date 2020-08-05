# @summary Setup SSHD daemon configuration
#
# Setup SSHD daemon configuration based on template
#
# @example
#   include openssh::config
class openssh::config (
  Stdlib::Unixpath
          $config                    = $openssh::config,
  Stdlib::Port
          $ssh_port                  = $openssh::ssh_port,
  String  $config_template           = $openssh::config_template,
  Variant[
    Enum['none'],
    Stdlib::Unixpath
  ]       $banner                    = $openssh::banner,
  Optional[String]
          $keys_file                 = $openssh::keys_file,
  Enum['yes', 'no', 'all', 'local', 'remote']
          $allow_tcp_forwarding      = $openssh::allow_tcp_forwarding,
  Enum['yes', 'no', 'without-password', 'prohibit-password', 'forced-commands-only']
          $permit_root_login         = $openssh::permit_root_login,
  Enum['yes', 'no']
          $strict_modes              = $openssh::strict_modes,
  Enum['yes', 'no']
          $gss_api_authentication    = $openssh::gss_api_authentication,
  # whether to add HostKey directives into sshd_config or not
  Boolean $setup_host_key            = $openssh::setup_host_key,
)
{
  file { $config:
    ensure  => present,
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
      'ssh-keygen -t ed25519 -P "" -f /etc/ssh/ssh_host_ed25519_key':
        creates => '/etc/ssh/ssh_host_ed25519_key',
      ;
    }
  }
}
