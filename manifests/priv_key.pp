# A description of what this defined type does
#
# @summary
#   Set SSH private key for user.
#
# @example
#   openssh::priv_key { 'namevar': }
#
# @param user_name
#   The name of system user for which private key should be set
#   Used for SSH directory compilation (either /root/.ssh if user is 'root' or /home/user_name/.ssh)
#   Used as ownership group if user_group is not specified
#   Used for SSH public key comment during public key generating
#
# @param key_data
#   SSH private key content
#
# @param sshkey_name
#   SSH public key comment (will be set if specified)
#
# @param sshkey_type
#   Default is 'rsa'
#   SSH private key type (eg rsa or dsa)
#   Used for SSH private and public key file name compilation (eg
#   .ssh/id_<key_id> where key_id is the type of key: dsa | ecdsa | ed25519 | rsa)
#
# @param user_group
#   Private key ownership group
#
# @param sshkey_dir
#   SSH directory which used for SSH keys storage instead of standard one
#   compiled based on user_name
#
# @param generate_public
#   if set - public key will be generated with suffix .pub based on private key
#
# @param key_prefix
#   if set - used for private and public file name compilation as prefix (eg
#   git.id_rsa where key_prefix is git)
#
define openssh::priv_key (
  String  $user_name,
  String  $key_data,
  Optional[String]
          $sshkey_name     = undef,
  Openssh::KeyType
          $sshkey_type     = 'ssh-rsa',
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
      user        => 'root',
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
        user        => 'root',
        subscribe   => Exec["generate ${pub_key}"],
      }
    }

    file { $pub_key:
      owner   => $user_name,
      group   => $key_owner_group,
      mode    => '0640',
      require => Exec["generate ${pub_key}"],
    }
  }
}
