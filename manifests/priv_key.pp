# @summary Set SSH private key for user.
#
# Set SSH private key for user.
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
# @param sshkey_format
#   Default is 'PEM'
#   The supported key formats are: "RFC4716" (RFC 4716/SSH2 public or private
#   key), "PKCS8" (PEM PKCS8 public key) or "PEM" (PEM public key). The default
#   conversion format for ssh-keygen tool is "RFC4716"
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
  Enum['present', 'absent'] $sshkey_ensure = present,
  Optional[String] $sshkey_name = $name,
  Openssh::KeyType $sshkey_type = 'ssh-rsa',
  Enum['PEM', 'RFC4716', 'PKCS8'] $sshkey_format = 'PEM',
  Optional[String] $user_group = $user_name,
  # in order to support non standard .ssh directory locations
  Optional[Stdlib::Unixpath] $sshkey_dir = undef,
  Boolean $generate_public = false,
  Optional[Pattern[/^[-a-z0-9]+$/]] $key_prefix = undef,
  Boolean $manage_ssh_dir  = false,
) {
  $sshkey_enable = ($sshkey_ensure == 'present')
  $hostname = $facts['networking']['hostname']

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
    default => "${user_name}@${hostname}",
  }

  case $sshkey_format {
    'PEM': {
      # encapsulation boundary name
      $eb_name = $id_type ? {
        'dsa'     => 'DSA',
        'ecdsa'   => 'EC',
        'ed25519' => 'OPENSSH',
        'rsa'     => 'RSA',
        default   => 'OPENSSH',
      }
    }
    default: {
      $eb_name = 'OPENSSH'
    }
  }

  # pre- and post-encapsulation boundary
  $pre_eb = "-----BEGIN ${eb_name} PRIVATE KEY-----"
  $post_eb = "-----END ${eb_name} PRIVATE KEY-----"

  # basic check
  unless $pre_eb in $key_data and $post_eb in $key_data {
    fail("Provided PEM key data is not valid for ${id_type} key")
  }

  if $sshkey_enable {
    # to create full path to key
    exec { $key_path:
      command => "mkdir -p ${ssh_dir}",
      path    => '/usr/bin:/bin',
      user    => $user_name,
      creates => $ssh_dir,
      before  => File[$key_path],
    }

    if $manage_ssh_dir {
      file { $ssh_dir:
        ensure  => directory,
        owner   => $user_name,
        group   => $user_group,
        mode    => '0700',
        require => Exec[$key_path],
      }
    }
  }

  file { $key_path:
    ensure  => $sshkey_ensure,
    content => $key_data,
    owner   => $user_name,
    group   => $user_group,
    mode    => '0600',
  }

  # add public key
  if $generate_public {
    if $sshkey_enable {
      exec { "generate ${pub_key}":
        command     => "ssh-keygen -f ${key_path} -y > ${pub_key}",
        path        => '/usr/bin:/bin',
        user        => 'root',
        creates     => $pub_key,
        refreshonly => true,
        subscribe   => File[$key_path],
        before      => File[$pub_key],
      }
    }

    # add comment to public key
    # on CentOS 6 ssh-keygen could edit only RSA1 keys
    if  $facts['os']['family'] == 'RedHat' and
    $facts['os']['release']['major'] in ['7', '8'] {
      file { "${key_path}.comm":
        ensure  => $sshkey_ensure,
        content => $key_data,
        owner   => $user_name,
        group   => $user_group,
        mode    => '0600',
        require => File[$key_path],
      }

      if $sshkey_enable {
        exec { "add ${pub_key} comment":
          command     => "ssh-keygen -f ${key_path}.comm -o -c -C ${pub_key_name}",
          refreshonly => true,
          path        => '/usr/bin:/bin',
          user        => 'root',
          subscribe   => Exec["generate ${pub_key}"],
          require     => File["${key_path}.comm"],
        }
      }
    }

    file { $pub_key:
      ensure => $sshkey_ensure,
      owner  => $user_name,
      group  => $user_group,
      mode   => '0640',
    }
  }
}
