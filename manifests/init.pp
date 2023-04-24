# @summary openssh main class (internal variables initialization)
#
# Openssh class for variables initialization
#
# @param hostbased_authentication
#   Specifies whether rhosts or /etc/hosts.equiv authentication together with
#   successful public key client host authentication is allowed (host-based
#   authentication).  This option is similar to RhostsRSAAuthentication and
#   applies to protocol version 2 only.  The default is "no".
#
# @param challenge_response_authentication
#   Specifies whether challenge-response authentication is allowed (e.g. via
#   PAM or though authentication styles supported in login.conf(5)) The default
#   is "yes".
#   see also https://access.redhat.com/solutions/336773
#
# @example
#   include openssh
class openssh (
  String $allow_tcp_forwarding,
  String $permit_root_login,
  String $strict_modes,
  String $gss_api_authentication,
  String $hostbased_authentication,
  Openssh::Switch $challenge_response_authentication,
  String $config_template,
  Optional[String] $use_privilege_separation,
  Optional[Integer[1,2]] $protocol,
  String $permit_tunnel,
  Openssh::Switch $password_authentication,
  Optional[String] $keys_file,
  String $banner,
  Boolean $manage_server_package,
  Boolean $manage_client_package,
  String $sshkey_user,
  Optional[String] $sshkey_group,
  String $sshkey_dir,
  Optional[String] $sshkey_name,
  String $sshkey_type,
  String $sshkey_target,
  Array[String] $sshkey_options,
  Boolean $setup_host_key,
  String $package_ensure,
  Boolean $setup_ed25519_key,
  String $client_package_ensure = $package_ensure,
  String $server_package_ensure = $package_ensure,
  Integer $ssh_port = $openssh::params::ssh_port,
  String $config = $openssh::params::config,
  String $base_package_name = $openssh::params::base_package_name,
  Optional[String] $server_package_name = $openssh::params::server_package_name,
  Optional[String] $client_package_name = $openssh::params::client_package_name,
  Optional[Array[String]] $server_dependencies = $openssh::params::openssh_server_dependencies,
  Optional[
    Variant[
      String,
      Array[Openssh::MACs]
    ]
  ]       $macs,
  Optional[
    Variant[
      String,
      Array[Openssh::Ciphers]
    ]
  ]       $ciphers,
  Optional[
    Variant[
      String,
      Array[Openssh::KexAlgorithms]
    ]
  ]       $kexalgorithms,
) inherits openssh::params {}
