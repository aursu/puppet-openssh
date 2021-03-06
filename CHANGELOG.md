# Changelog

All notable changes to this project will be documented in this file.

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