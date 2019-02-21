# A description of what this defined type does
#
# @summary A short summary of the purpose of this defined type.
#
# @example
#   openssh::priv_key { 'namevar': }
define openssh::priv_key (
  String  $user_name,
  String  $key_data,
  Optional[String]
          $sshkey_name     = $name,
  Openssh::KeyType
          $sshkey_type     = 'rsa',
  Optional[String]
          $user_group      = undef,
  # in order to support non standard .ssh directory locations
  Optional[Stdlib::Unixpath]
          $sshkey_dir      = undef,
  Boolean $generate_public = false,
  Optional[Pattern[/^[-a-z0-9]+$/]]
          $key_prefix      = undef,
)
{
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

  $key_owner_group = $user_group ? {
    String  => $user_group,
    default => $user_name,
  }

  $id_type = $sshkey_type ? {
    /-dss/    => 'dsa',
    'dsa'     => 'dsa',
    /ecdsa-/  => 'ecdsa',
    /ed25519/ => 'ed25519',
    default   => 'rsa',
  }

  if $key_prefix {
    $key_path = "${ssh_dir}/${key_prefix}.id_${id_type}"
  }
  else {
    $key_path = "${ssh_dir}/id_${id_type}"
  }
  $pub_key  = "${key_path}.pub"

  $pub_key_name = $sshkey_name ? {
    String  => $sshkey_name,
    default => "${user_name}@${::hostname}",
  }

  # encapsulation boundary name
  $eb_name = $id_type ? {
    'dsa'     => 'DSA',
    'ecdsa'   => 'EC',
    'ed25519' => 'OPENSSH',
    default   => 'RSA',
  }

  # pre- and post-encapsulation boundary
  $pre_eb = "-----BEGIN ${eb_name} PRIVATE KEY-----"
  $post_eb = "-----END ${eb_name} PRIVATE KEY-----"

  # basic check
  unless $pre_eb in $key_data and $post_eb in $key_data {
    fail("Provided PEM key data is not valid for ${id_type} key")
  }

  exec { "create ${key_path} path":
    command => "mkdir -p ${ssh_dir}",
    path    => '/usr/bin:/bin',
    user    => $user_name,
    creates => $ssh_dir,
  }

  file { $key_path:
    content => $key_data,
    owner   => $user_name,
    group   => $key_owner_group,
    mode    => '0600',
    require => Exec["create ${key_path} path"],
  }

  # add public key
  if $generate_public {
    exec { "generate ${pub_key}":
      command     => "ssh-keygen -f ${key_path} -y > ${pub_key}",
      refreshonly => true,
      path        => '/usr/bin:/bin',
      user        => $user_name,
      subscribe   => File[$key_path],
    }
    # add comment to public key
    # on CentOS 6 ssh-keygen could edit only RSA1 keys
    if  $facts['os']['name'] in ['RedHat', 'CentOS'] and
        $facts['os']['release']['major'] in ['7', '8'] {
      exec { "add ${pub_key} comment":
        command     => "ssh-keygen -f ${key_path} -c -C ${pub_key_name}",
        refreshonly => true,
        path        => '/usr/bin:/bin',
        user        => $user_name,
        subscribe   => Exec["generate ${pub_key}"],
      }
    }
  }
}
