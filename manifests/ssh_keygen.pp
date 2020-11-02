# @summary A short summary of the purpose of this class
#
# Generate new OpenSSH private key or export root public key
#
# @example
#   include openssh::ssh_keygen
class openssh::ssh_keygen (
  String  $sshkey_name            = $openssh::sshkey_name,
  String  $sshkey_user            = $openssh::sshkey_user,
  Openssh::KeyType
          $sshkey_type            = $openssh::sshkey_type,
  Stdlib::Unixpath
          $sshkey_target          = $openssh::sshkey_target,
  Stdlib::Unixpath
          $sshkey_dir             = $openssh::sshkey_dir,
  Array[String]
          $sshkey_options         = $openssh::sshkey_options,
  String  $sshkey_ensure          = present,
  Integer $sshkey_bits            = 2048,
  Boolean $root_key_export        = true,
  Boolean $sshkey_generate_enable = false,
)
{
  include openssh::keys

  # -t dsa | ecdsa | ed25519 | rsa
  $type = $sshkey_type ? {
    /-dss/    => 'dsa',
    'dsa'     => 'dsa',
    /ecdsa-/  => 'ecdsa',
    /ed25519/ => 'ed25519',
    default   => 'rsa',
  }

  if $sshkey_generate_enable {
    # ~/.ssh/id_dsa
    # ~/.ssh/id_ecdsa
    # ~/.ssh/id_ed25519
    # ~/.ssh/id_rsa
    $filename = "${sshkey_dir}/id_${type}"

    exec { "ssh-keygen-${sshkey_user}":
      command => "ssh-keygen -t ${type} -b ${sshkey_bits} -f \"${filename}\" -N '' -C \"${sshkey_name}\"",
      user    => $sshkey_user,
      creates => $filename,
      path    => '/usr/bin:/bin',
      require => File[$sshkey_dir],
    }
  }
  # Export root user public key
  elsif $root_key_export and $sshkey_user == 'root' and $facts['sshpubkey_root'] {
    $sshkey = $facts['sshpubkey_root']

    if $sshkey_type in $sshkey and $sshkey_name in $sshkey {
      $sshkey_export = $sshkey[1]
    }
    else {
      $sshkey_export = undef
      warning("Can't parse root ssh public key from ${::fqdn}")
    }

    if $sshkey_export {
      @@ssh_authorized_key { $sshkey_name:
        ensure  => $sshkey_ensure,
        key     => $sshkey_export,
        user    => $sshkey_user,
        target  => $sshkey_target,
        options => $sshkey_options,
        type    => $sshkey_type,
      }
    }
  }
}
