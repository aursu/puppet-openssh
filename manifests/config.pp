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
)
{
  file { $config:
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => template($config_template),
  }
}