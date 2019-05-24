# @summary A short summary of the purpose of this defined type.
#
# A description of what this defined type does
#
# @example
#   openssh::auth_key { 'namevar': }
define openssh::auth_key (
  String  $sshkey_user,
  Enum['present', 'absent']
          $sshkey_ensure    = present,
  String  $sshkey_name      = $name,
  Openssh::KeyType
          $sshkey_type      = 'rsa',
  Boolean $sshkey_propagate = false,
  Optional[Stdlib::Unixpath]
          $sshkey_target    = undef,
  Optional[Array[String]]
          $sshkey_options   = undef,
  Optional[Stdlib::Base64]
          $sshkey           = undef,
  Boolean $sshkey_export    = false,
) {

  # compile user home directory
  $user_home = $sshkey_user ? {
    'root' => '/root',
    default => "/home/${sshkey_user}",
  }

  $user_ssh_dir = "${user_home}/.ssh"

  $ssh_dir = $sshkey_target ? {
    Stdlib::Unixpath => dirname($sshkey_target),
    default          => $user_ssh_dir,
  }

  # The absolute filename in which to store the SSH key.
  $auth_target = $sshkey_target ? {
    Stdlib::Unixpath => $sshkey_target,
    default          => "${ssh_dir}/authorized_keys",
  }

  exec { "create ${auth_target} path":
    command => "mkdir -p ${ssh_dir}",
    path    => '/usr/bin:/bin',
    user    => $sshkey_user,
    creates => $ssh_dir,
  }

  if $sshkey_propagate {
    Ssh_authorized_key <<| title == $sshkey_name |>>
  }
  elsif $sshkey {
    ssh_authorized_key { $sshkey_name:
      ensure  => $sshkey_ensure,
      user    => $sshkey_user,
      type    => $sshkey_type,
      target  => $sshkey_target,
      options => $sshkey_options,
      key     => $sshkey,
      require => Exec["create ${auth_target} path"],
    }

    if $sshkey_export {
      @@sshkey { "${::fqdn}_${sshkey_user}_known_host":
        host_aliases => [$::hostname, $::fqdn, $::ipaddress],
        key          => $sshkey,
        target       => "${user_ssh_dir}/known_hosts",
        type         => $sshkey_type,
      }
    }
  }
}
