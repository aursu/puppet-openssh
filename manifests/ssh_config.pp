# A description of what this defined type does
#
# @summary A short summary of the purpose of this defined type.
#
# @example
#   openssh::ssh_config { 'namevar': }
define openssh::ssh_config (
  Array[Openssh::SshConfig] $ssh_config,
  String $user_name = $name,
  Optional[String] $user_group = undef,
  # only when user_name is 'root'
  Boolean $system_wide = false,
  Optional[Stdlib::Unixpath] $system_path = undef,
  Optional[Stdlib::Unixpath] $sshkey_dir = undef,
) {
  # compile user home directory
  $user_home = $user_name ? {
    'root' => '/root',
    default => "/home/${user_name}",
  }

  $user_ssh_dir = "${user_home}/.ssh"

  $ssh_dir = $sshkey_dir ? {
    Stdlib::Unixpath => $sshkey_dir,
    default          => $user_ssh_dir,
  }

  if $system_wide {
    if $user_name == 'root' {
      if $system_path {
        $config_path = $system_path
      }
      else {
        $config_path = '/etc/ssh/ssh_config'
      }
      $config_owner_group = 'root'
      $config_mode = '0644'
    }
    else {
      fail("You can setup system SSH config /etc/ssh/ssh_config only for user root (not ${user_name})")
    }
  }
  else {
    $config_path = "${ssh_dir}/config"
    $config_owner_group = $user_group ? {
      String  => $user_group,
      default => $user_name,
    }
    $config_mode = '0600'

    if $ssh_config[0] {
      exec { $config_path:
        command => "mkdir -p ${ssh_dir}",
        path    => '/usr/bin:/bin',
        user    => $user_name,
        creates => $ssh_dir,
        before  => File[$config_path],
      }
    }
  }

  # if $ssh_config is not empty
  if $ssh_config[0] {
    file { $config_path:
      content => epp('openssh/ssh_config.epp', { 'ssh_config' => $ssh_config, }),
      owner   => $user_name,
      group   => $config_owner_group,
      mode    => $config_mode,
    }
  }
}
