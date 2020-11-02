# @summary Basic OpenSSH profile
#
# Basic OpenSSH profile
#
# @param sshkey_name
#   Name to use for new authorized key record for user root
#
# @sshkey
#   SSH public key content to insert innto authorized keys file
#
# @example
#   include openssh::profile::server
class openssh::profile::server (
  Optional[String]
          $sshkey_name = lookup({ 'name' => 'openssh::sshkey_name', 'default_value' => undef }),
  Optional[String]
          $sshkey      = lookup({ 'name' => 'openssh::keys::sshkey', 'default_value' => undef }),
)
{
  include openssh
  class { 'openssh::package':
    manage_client => true,
    manage_server => true,
  }
  class { 'openssh::config': }
  class { 'openssh::keys':
    sshkey_propagate => false,
    sshkey_name      => $sshkey_name,
    sshkey           => $sshkey,
  }
  class { 'openssh::service': }

  Class['openssh::config'] ~> Class['openssh::service']
}
