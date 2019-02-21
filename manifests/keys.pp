# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include openssh::keys
class openssh::keys (
  Boolean $sshkey_enable    = $openssh::sshkey_enable,
  String  $sshkey_ensure    = present,
  Boolean $sshkey_propagate = false,
  Optional[String]
          $sshkey_group     = $openssh::sshkey_group,
  String  $sshkey_user      = $openssh::sshkey_user,
  Openssh::KeyType
          $sshkey_type      = $openssh::sshkey_type,
  Optional[String]
          $sshkey_name      = $openssh::sshkey_name,
  Stdlib::Unixpath
          $sshkey_dir       = $openssh::sshkey_dir,
  Stdlib::Unixpath
          $sshkey_target    = $openssh::sshkey_target,
  Array[String]
          $sshkey_options   = $openssh::sshkey_options,
  Optional[Stdlib::Base64]
          $sshkey           = undef,
  Optional[
    Array[
      Struct[{
        type => String,
        key  => String,
        name => String,
      }]
    ]
  ]       $authorized       = undef,
) {
  if $authorized {
    file { '/root/.ssh/authorized_keys':
      ensure  => present,
      content => template('openssh/authorized_keys.erb'),
    }
  }
  elsif $sshkey_enable {
    $defined_sshkey_group = $sshkey_group ? {
      String  => $sshkey_group,
      default => $sshkey_user,
    }

    file { $sshkey_dir:
        ensure => directory,
        group  => $defined_sshkey_group,
        mode   => '0700',
        owner  => $sshkey_user,
    }

    if $sshkey and $sshkey_name {
      if $sshkey_propagate {
        Ssh_authorized_key <<| title == $sshkey_name |>>
      }
      else {
        ssh_authorized_key { $sshkey_name:
          ensure  => $sshkey_ensure,
          user    => $sshkey_user,
          type    => $sshkey_type,
          target  => $sshkey_target,
          options => $sshkey_options,
          key     => $sshkey,
          require => File[$sshkey_dir],
        }
      }
    }

    @@sshkey { "${::fqdn}__root_known_host":
      host_aliases => [$::hostname, $::fqdn, $::ipaddress],
      key          => $::sshrsakey,
      target       => '/root/.ssh/known_hosts',
      type         => ssh-rsa,
      require      => File[$sshkey_dir],
    }
  }
}
