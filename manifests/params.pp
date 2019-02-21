# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include openssh::params
class openssh::params {
  $base_package_name = 'openssh'

  if $facts['os']['name'] in ['RedHat', 'CentOS'] {
    $server_package_name = 'openssh-server'
    $client_package_name = 'openssh-clients'
    if $facts['os']['release']['major'] in ['7', '8'] {
      $openssh_server_dependencies = ['initscripts']
    }
    else {
      $openssh_server_dependencies = undef
    }
  }
  else {
    # if not RedHat - no support
    $server_package_name = undef
    $client_package_name = undef
    $openssh_server_dependencies = undef
  }

  $service_name    = 'sshd'
  # sshd(8) reads configuration data from /etc/ssh/sshd_config (or the file
  # specified with -f on the command line)
  $config          = '/etc/ssh/sshd_config'
  $ssh_port        = 22
}
