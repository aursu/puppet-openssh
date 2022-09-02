# Manage OpenSSH daemon and client packages
#
# @summary Manage OpenSSH daemon and client packages
#
# @example
#   include openssh::package
class openssh::package (
  String  $package_ensure       = $openssh::package_ensure,
  String  $client_ensure        = $openssh::client_package_ensure,
  String  $server_ensure        = $openssh::server_package_ensure,
  String  $package_name         = $openssh::base_package_name,
  Boolean $manage_client        = $openssh::manage_client_package,
  Optional[String]
          $client_package       = $openssh::client_package_name,
  Boolean $manage_server        = $openssh::manage_server_package,
  Optional[String]
          $server_package       = $openssh::server_package_name,
  Optional[
    Array[String]
  ]       $server_dependencies  = $openssh::server_dependencies,
) {
  if $facts['os']['name'] in ['RedHat', 'CentOS'] {
    package { $package_name :
      ensure   => $package_ensure,
      provider => 'yum',
    }
  }

  if $manage_client and $client_package {
    package { $client_package:
      ensure => $client_ensure,
    }
  }

  if $manage_server and $server_package {
    if $server_dependencies {
      package { $server_dependencies:
        ensure => 'present',
      }
    }
    package { $server_package:
      ensure => $server_ensure,
    }
  }
}
