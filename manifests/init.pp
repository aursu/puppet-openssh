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
# @param listen_address
#   Addresses sshd listens on, one ListenAddress directive per entry. Undef
#   (the default) emits none, leaving sshd on the wildcard address, which is
#   its own default and the previous behaviour of this module.
#
#   Use it to keep sshd off interfaces it has no business on - a host with
#   container bridges answers SSH on every one of them by default.
#
#   Addresses must carry no prefix length: `10.0.0.10`, not `10.0.0.10/24`.
#   The type enforces that, because the value is usually copied from somewhere
#   that writes CIDR - an interface definition or `ip addr` output - and sshd
#   refuses to start on a malformed ListenAddress.
#
#   Setting this can lock you out of a host. sshd binds only what is listed, so
#   an address that does not exist on the machine, or one that your own route
#   to the host does not use, removes your access at the next restart. Verify
#   against the running interfaces first, and keep a second session open.
#
# @param config_dir
#   Drop-in directory that sshd_config pulls in with an Include.
#
# @param manage_config_dir
#   Whether to manage that directory as a resource.
#
# @param purge_config_dir
#   Whether to remove files in config_dir that Puppet does not manage.
#
#   Default true, and that is a deliberate reversal of the usual caution about
#   purging. sshd takes the FIRST occurrence of a keyword, and the Include sits
#   at the top of the file this module writes - so any drop-in silently
#   overrides everything below it. A stray file there does not merely add
#   settings, it defeats them, and the configuration still reads as applied.
#
#   Measured on a live estate: cloud-init writes
#   `50-cloud-init.conf` containing `PasswordAuthentication yes`, which
#   overrode this module's `PasswordAuthentication no` on every cloud-imaged
#   host. Nothing in sshd_config revealed it; only `sshd -T` did.
#
#   Set false where drop-ins are managed by something else on purpose. Before
#   turning it on for the first time, read what is in the directory - a
#   purge cannot distinguish a vendor default from a deliberate local setting,
#   and anything worth keeping should move into this module's parameters
#   rather than survive as a file.
#
# @example
#   include openssh
#
# @example Bind sshd to two internal addresses
#   class { 'openssh':
#     listen_address => ['10.100.16.12', '10.100.17.12'],
#   }
class openssh (
  String $allow_tcp_forwarding,
  String $permit_root_login,
  String $strict_modes,
  String $gss_api_authentication,
  String $hostbased_authentication,
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
  Optional[
    Array[
      Variant[
        String,
        Hash[String, String]
      ]
    ]
  ] $install_options,
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
  Optional[
    Variant[
      String,
      Array[Openssh::HostKeyAlgorithms]
    ]
  ]       $hostkeyalgorithms,
  Integer[1] $max_sessions = 5,
  Openssh::Switch $use_dns = false,
  String $client_package_ensure = $package_ensure,
  String $server_package_ensure = $package_ensure,
  Integer $ssh_port = $openssh::params::ssh_port,
  String $config = $openssh::params::config,
  String $base_package_name = $openssh::params::base_package_name,
  Optional[String] $server_package_name = $openssh::params::server_package_name,
  Optional[String] $client_package_name = $openssh::params::client_package_name,
  Optional[Array[String]] $server_dependencies = $openssh::params::openssh_server_dependencies,
  Optional[String] $config_template = $openssh::params::config_template,
  Optional[Tuple[Integer[0], Integer[0, 100], Integer[0]]] $max_startups = undef,
  Optional[Array[Stdlib::IP::Address::Nosubnet, 1]] $listen_address = undef,
  Stdlib::Absolutepath $config_dir = $openssh::params::config_dir,
  Boolean $manage_config_dir = true,
  Boolean $purge_config_dir = true,
) inherits openssh::params {}
