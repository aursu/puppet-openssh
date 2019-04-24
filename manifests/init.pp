# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include openssh
class openssh (
  String $allow_tcp_forwarding,
  String $permit_root_login,
  String $strict_modes,
  String $gss_api_authentication,
  String $config_template,
  Optional[String]
          $keys_file,
  String  $banner,
  Boolean $manage_server_package,
  Boolean $manage_client_package,
  Boolean $sshkey_enable,
  String  $sshkey_user,
  Optional[String]
          $sshkey_group,
  String  $sshkey_dir,
  Optional[String]
          $sshkey_name,
  String  $sshkey_type,
  String  $sshkey_target,
  Array[String]
          $sshkey_options,
  Boolean $enable_monit,
  Integer $ssh_port               = $openssh::params::ssh_port,
  String  $config                 = $openssh::params::config,
  String  $base_package_name      = $openssh::params::base_package_name,
  Optional[String]
          $server_package_name    = $openssh::params::server_package_name,
  Optional[String]
          $client_package_name    = $openssh::params::client_package_name,
  Optional[
    Array[String]
  ]       $server_dependencies    = $openssh::params::openssh_server_dependencies,
) inherits openssh::params {}
