# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include openssh::package
class openssh::package (
  String  $package_ensure       = present,
  String  $client_ensure        = present,
  String  $server_ensure        = present,
  String  $package_name         = $openssh::base_package_name,
  Boolean $manage_client        = $openssh::manage_client_package,
  Optional[String]
          $client_package       = $openssh::client_package_name,
  Boolean $manage_server        = $openssh::manage_server_package,
  Optional[String]
          $server_package       = $openssh::server_package_name,
  Optional[
    Array[String]
  ]       $server_dependencies  = $openssh::openssh_server_dependencies,
)
{
  package { $package_name :
    ensure => $package_ensure,
  }

  if $manage_client and $client_package {
    package { $client_package:
      ensure => $client_ensure,
    }
  }

  if $manage_server and $server_package {
    if $server_dependencies {
      package { $server_dependencies:
        ensure => $server_ensure,
      }
    }
    package { $server_package:
      ensure => $server_ensure,
    }
  }
}
