# Changelog

All notable changes to this project will be documented in this file.

## Release 0.15.0

**Bugfixes**

* **The drop-in directory is no longer purged where the configuration does not
  read it.** `manage_config_dir` now defaults to whether the rendered
  sshd_config carries an `Include` at all - true on Debian, false on RedHat,
  whose template has none. 0.13.0 turned purging on for everyone, and the note
  there was right that RedHat is unaffected in practice because the drop-ins
  are never read; it did not follow that through to deletion. Rocky 10 ships
  `40-redhat-crypto-policies.conf` and `50-redhat.conf` in that directory, and
  a purge removed both. Nothing broke while this module owned sshd_config, but
  `40-redhat-crypto-policies.conf` is how the system-wide crypto policy reaches
  sshd, so a host that later returned to the distribution's configuration - a
  package reinstall, this module removed, a hand edit during an incident -
  would have lost that integration silently.

**Notes**

* Purging remains on by default where the Include exists, which is what it was
  introduced for: a drop-in that precedes the settings below it overrides them.
  Where nothing is included there is nothing to override.
* `manage_config_dir: true` still turns management on explicitly, purge and
  all, on any platform.
* The new `openssh::params::config_include` exists so this tracks the templates
  rather than a second opinion about them.

## Release 0.14.0

**Breaking changes**

* **CentOS 6 and CentOS 7 are no longer supported.** They left
  `operatingsystem_support`, and with them went `data/os/RedHat/CentOS/7.yaml`,
  the `initscripts` server dependency, the `yum` package provider, the EL6
  cipher/MAC/KEX lists, and the EL5/EL6 branch that disabled ed25519 host keys.
  The systemd drop-in in `openssh::service` and the public-key comment file in
  `openssh::priv_key` were gated on releases 7 and 8; they are now EL8 only.
* **Three class parameters are removed**: `protocol`,
  `use_privilege_separation` and `challenge_response_authentication`. The
  directives they rendered were dropped from the templates in 0.13.0, so the
  parameters have been inert since then. `Protocol` and
  `UsePrivilegeSeparation` were removed from OpenSSH in 7.4 and 7.5; no
  supported release accepts them. Hiera keys still setting them are simply not
  read any more - nothing fails

**Features**

* **Rocky Linux 10 is declared supported.** The configuration this module
  renders was checked against the release's own `openssh-server-9.9p1`: `sshd -t`
  accepts it without a warning

**Bugfixes**

**Known Issues**

## Release 0.13.0

**Features**

* **The sshd_config.d drop-in directory is now managed and purged by default.** New parameters
  `config_dir`, `manage_config_dir` and `purge_config_dir`.

**Bugfixes**

* **A drop-in silently defeated this module's configuration.** sshd honours the FIRST occurrence
  of a keyword, and the `Include` sits at the top of the file this module writes - so a file in
  `sshd_config.d` does not supplement the settings below it, it overrides them. Measured on a
  live estate: cloud-init ships `50-cloud-init.conf` with `PasswordAuthentication yes`, which
  beat this module's `PasswordAuthentication no` on every cloud-imaged host. Nothing in
  sshd_config showed it - only `sshd -T` did.

**Notes**

* Purging is on by default deliberately, against the usual caution. The failure it prevents is
  not an untidy directory but a configuration that reads as applied and is not, which is the
  same class of defect as the socket-activation bug fixed in 0.12.0.
* **Read the directory before enabling it on an existing estate.** A purge cannot tell a vendor
  default from a deliberate local setting. Anything worth keeping belongs in this module's
  parameters, not in a file that survives by exception - `AllowTcpForwarding` was found being
  set this way on one host and had to move to `openssh::allow_tcp_forwarding` first.
* The `Include` in the Debian template now follows `config_dir`, so the directory Puppet purges
  and the directory sshd reads cannot drift apart.
* The purge notifies the same reload and socket restart as an sshd_config edit, because removing
  a drop-in changes the effective configuration exactly as editing the file does.
* RedHat is unaffected in practice: that template carries no `Include`, so drop-ins were never
  read there.

## Release 0.12.0

**Bugfixes**

* **`listen_address` now reaches the listener on socket-activated hosts.** 0.11.0 wrote
  `ListenAddress` into sshd_config and reloaded the service, which on Ubuntu 22.10 and newer
  changes nothing: sshd does not perform the bind there. systemd owns the socket, and its
  addresses come from a unit fragment that `sshd-socket-generator` derives from sshd_config.
  That generator only re-runs on `systemctl daemon-reload`, and the socket has to be restarted
  afterwards to bind what it produced. The result was a restriction that `sshd -T` reported and
  `ss` contradicted - it read as applied and was not. Measured on Ubuntu 24.04.

**Features**

* `openssh::config` notifies `bsys::systemctl::daemon_reload` on **any** sshd_config change, and
  `openssh::service` restarts the socket unit after it. Two steps rather than one command,
  because they are two different things: the reload re-runs the generator, the restart binds
  what it wrote.
* Notified on every change rather than on `ListenAddress` alone. The generator reads `Port` too,
  and a reload is cheap and harmless where nothing is socket-activated - which also means no
  comparison of old and new addresses has to be computed or kept correct.
* New parameters `openssh::service::manage_socket` (default true) and
  `openssh::params::socket_name` (`ssh.socket` on Debian, `sshd.socket` elsewhere).
* The restart Exec is titled `restart-<unit>-1b7dac3`, where the digest is
  `sha256('openssh::service')[0,7]`, matching the convention in
  `bsys::systemctl::daemon_reload`. A plain "restart ssh.socket" is the title another module
  would reasonably choose for the same unit, and the second one to do so would be a duplicate
  declaration. The digest is written out rather than computed - the input is a literal, so the
  value never varies.
* The restart is guarded by **`systemctl is-enabled`** at apply time, not by a fact at catalogue
  time. That keeps it a no-op on hosts without socket activation, and it is also what makes a
  first run correct: the check runs after the package resource, so there is no compile-time
  guess to be wrong about and nothing left to converge on a second run.

**Notes**

* **No drop-in is written.** An earlier draft wrote `ssh.socket.d/listen-address.conf` by hand.
  That was unnecessary and wrong: the distribution already generates exactly that file,
  including the `ListenStream=` reset needed to clear the inherited wildcard, and a hand-written
  copy would compete with it on every `daemon-reload`. The generator stays the source of truth.
* Adds a dependency on `aursu/bsys` for `bsys::systemctl::daemon_reload`.

## Release 0.11.0

**Features**

* Added ListenAddress parameter, so sshd can be bound to specific addresses instead of the
  wildcard. Accepts an array and emits one ListenAddress directive per entry, which is what
  sshd expects - it takes repeated directives rather than a joined list.
* Defaults to undef, which emits nothing and leaves sshd on the wildcard address. Existing
  consumers are unaffected, and a spec asserts the commented-out defaults still render so an
  upgrade cannot silently start restricting where sshd listens.
* Typed as Stdlib::IP::Address::Nosubnet rather than Stdlib::IP::Address, which rejects a
  prefix length at catalogue time. `10.0.0.10/24` is the likeliest mistake, because the value
  is usually copied from an interface definition or `ip addr` output, and sshd refuses to
  start on a malformed ListenAddress. An empty array is rejected for the same reason - it
  would be indistinguishable from undef while reading like an intent to restrict.
* Added RSpec coverage for rendering (none, single, several, IPv6) and for the rejected forms.

**Bugfixes**

**Known Issues**

* This parameter can lock you out of a host. sshd binds only what is listed, so an address
  that is not present on the machine, or one that your route to the host does not use, removes
  access at the next restart. Verify against the running interfaces and keep a second session
  open. The module deliberately does not validate the address against node facts: an address
  configured earlier in the same run would not yet appear in them, and failing that case would
  be worse than the problem it prevents.

## Release 0.10.0

**Features**

* Added MaxStartups parameter with validation (start:rate:full format)
* Added MaxSessions parameter with default value of 5
* Added UseDNS parameter with default value of 'no'
* Added comprehensive RSpec tests for all new parameters
* Added runtime validation for MaxStartups to ensure full >= start

**Bugfixes**

**Known Issues**

## Release 0.9.9

**Features**

* PDK upgrade to 3.6.1

**Bugfixes**

* Bugfix for empty settings' array

**Known Issues**

## Release 0.1.0

**Features**

**Bugfixes**

**Known Issues**

## Release 0.4.5

**Features**

* Added flag manage_sshkey_target to disable sshkey_target directory management

**Bugfixes**

**Known Issues**

## Release 0.4.6

**Features**

* Set sshkey_name to defined resource title for uniquness
* Disable sshkey_export by default

**Bugfixes**

* Bugfix for dependency on sshkey_target directory management Exec

**Known Issues**

## Release 0.4.7

**Features**

**Bugfixes**

* Corrected parameter name in openssh::package

**Known Issues**

## Release 0.4.8

**Features**

* Added ability to tag exported sshkey resources

**Bugfixes**

**Known Issues**

## Release 0.4.9

**Features**

* Added Openssh::Switch type to use true/false for some parameters
* Added boolean to challenge_response_authentication and password_authentication
  parameter

**Bugfixes**

**Known Issues**

## Release 0.4.10

**Features**

* Added hardening for OpenSSH binaries

**Bugfixes**

**Known Issues**

## Release 0.5.0

**Features**

**Bugfixes**

* Fixed sshd config template to properly interpret switch  parameters

**Known Issues**

## Release 0.6.0

**Features**

* Added custom path to system wide SSH configuration file
  to allow setting up /etc/ssh/ssh_config.d/*.conf

**Bugfixes**

**Known Issues**

## Release 0.6.2

**Features**

**Bugfixes**

* Bugfix for Ubuntu

**Known Issues**

## Release 0.6.3

**Features**

* Added ability to define custom_ssh_keys for profile openssh::profile::server

**Bugfixes**

* Improved user root key export integrity
* Added some Ubuntu 18.04 support

**Known Issues**

## Release 0.6.4

**Features**

* Added type Openssh::SshKey

**Bugfixes**

* Corrected `custom_ssh_keys` parameter type for profile `openssh::profile::server`

**Known Issues**

## Release 0.6.5

**Features**

**Bugfixes**

* Added workaround for SSH public key comment setup

**Known Issues**

## Release 0.6.6

**Features**

* Added $sshkey_ensure flag for openssh::priv_key

**Bugfixes**

* Added $sshkey_enable to manage exec resources in openssh::auth_key

**Known Issues**

## Release 0.6.7

**Features**

**Bugfixes**

* Fixed resource dependencies

**Known Issues**

## Release 0.6.8

**Features**

* Added ability to disable ed25519 key setup

**Bugfixes**

**Known Issues**

## Release 0.6.9

**Features**

* PDK upgrade to version 2.3.0

**Bugfixes**

**Known Issues**

## Release 0.7.0

**Features**

* Added Rocky Linux 8 support
* Added user's ssh directory management in priv_key

**Bugfixes**

**Known Issues**

## Release 0.8.0

**Features**

* PDK upgrade to 3.0.0

**Bugfixes**

**Known Issues**

## Release 0.9.0

**Features**

* Added type Openssh::KeyID

**Bugfixes**

**Known Issues**

## Release 0.9.2

**Features**

* Added `sshkey_export_tag` into openssh::keys
* Added `export_tags_extra` for an additional list of tags

**Bugfixes**

**Known Issues**

## Release 0.9.3

**Features**

* Added `install_options` to pass to package installations
* Added `HostKeyAlgorithms` into openssh sshd_config

**Bugfixes**

**Known Issues**

## Release 0.9.4

**Features**

* Added `sshkey` export resources for all existing host keys

**Bugfixes**

**Known Issues**

## Release 0.9.5

**Features**

**Bugfixes**

* Corrected `base_package_name` and `package_provider` for Ubuntu OS

**Known Issues**

## Release 0.9.8

**Features**

**Bugfixes**

* Corrected service name for Ubuntu OS
* Pacakge installation on CentOS 6
* SFTP on Ubuntu OS

**Known Issues**
