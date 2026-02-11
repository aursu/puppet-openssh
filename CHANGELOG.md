# Changelog

All notable changes to this project will be documented in this file.

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
