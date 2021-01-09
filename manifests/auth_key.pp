# @summary Setup authorized keys for system user
#
# Setup authorized keys for system user
#
# @example
#   openssh::auth_key { 'namevar': }
#
# @param sshkey_user
#   The user account in which the SSH key should be installed
#
# @param sshkey_ensure
#
# @param sshkey_type
#
# @param sshkey_name
#   The The SSH key name/comment. In their native habitat, SSH keys usually
#   appear as a single long line, in the format: `<TYPE>` `<KEY>` `<NAME/COMMENT>`
#
# @param sshkey_target
#
# @param sshkey_options
#
# @param sshkey
#
# @param sshkey_export
#   Boolean flag. If set to true `openssh::auth_key` resource will export ssh
#   host key via resource `Sshkey` with title equal to
#   `<fqdn>_<sshkey_user>_known_host`
#   where `<fqdn>` is puppet fact `$::fqdn` and `<sshkey_user>` is `sshkey_user`
#   parameter.
#   The `Sshkey` resource's `target` parameter will be set to
#   `~/.ssh/known_hosts` path for user `sshkey_user` (with home directory
#   `/root` for user `root` and `/home/<sshkey_user>` for all other users)
#
# @param sshkey_propagate
#   Boolean flag. If set to true `openssh::auth_key` resource will import
#   `Ssh_authorized_key` resource with title equal:
#     1) to either parameter `sshkey_name` or
#     2) to name combined from parameter `sshkey_user` and fact `$::hostname` as
#       string `<sshkey_user>@<hostname>`
#
define openssh::auth_key (
  String  $sshkey_user,
  Enum['present', 'absent']
          $sshkey_ensure        = present,
  Openssh::KeyType
          $sshkey_type          = 'ssh-rsa',
  Optional[String]
          $sshkey_name          = $name,
  Optional[Stdlib::Unixpath]
          $sshkey_target        = undef,
  Boolean $manage_sshkey_target = true,
  Optional[Array[String]]
          $sshkey_options       = undef,
  Optional[Stdlib::Base64]
          $sshkey               = undef,
  Boolean $sshkey_export        = false,
  Boolean $sshkey_propagate     = false,
) {
  # find out user home directory
  $user_home = $sshkey_user ? {
    'root'  => '/root',
    default => "/home/${sshkey_user}",
  }

  # user ssh configuration directory (usually ~/.ssh)
  $user_ssh_dir = "${user_home}/.ssh"

  # directory that contains authorized_keys file
  $ssh_dir = $sshkey_target ? {
    Stdlib::Unixpath => dirname($sshkey_target),
    default          => $user_ssh_dir,
  }

  # The absolute filename in which to store the SSH key.
  $auth_target = $sshkey_target ? {
    Stdlib::Unixpath => $sshkey_target,
    default          => "${ssh_dir}/authorized_keys",
  }

  $pub_key_name = $sshkey_name ? {
    String  => $sshkey_name,
    default => "${sshkey_user}@${::hostname}",
  }

  if $manage_sshkey_target {
    exec { "mkdir dirname(${auth_target}) for ${pub_key_name}":
      command => "mkdir -p ${ssh_dir}",
      path    => '/usr/bin:/bin',
      user    => $sshkey_user,
      creates => $ssh_dir,
    }
  }

  if $sshkey_propagate {
    Ssh_authorized_key <<| title == $pub_key_name |>>
  }
  elsif $sshkey {
    ssh_authorized_key { $pub_key_name:
      ensure  => $sshkey_ensure,
      user    => $sshkey_user,
      type    => $sshkey_type,
      target  => $sshkey_target,
      options => $sshkey_options,
      key     => $sshkey,
      require => Exec["mkdir dirname(${auth_target})"],
    }
  }

  if $sshkey_export and $facts['ssh'] and $facts['ssh']['ecdsa'] {
    @@sshkey { "${::fqdn}_${sshkey_user}_known_host":
      host_aliases => [$::hostname, $::fqdn, $::ipaddress],
      key          => $facts['ssh']['ecdsa']['key'],
      target       => "${user_ssh_dir}/known_hosts",
      type         => $facts['ssh']['ecdsa']['type']
    }
  }
}
