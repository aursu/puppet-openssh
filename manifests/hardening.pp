# @summary SSH client and server files hardening
#
# SSH client and server files hardening
#
# @example
#   include openssh::hardening
class openssh::hardening {
  file {
    default: mode => 'o=';
    # sshd
    '/usr/sbin/sshd': ;
    '/usr/sbin/sshd-keygen': ;

    # openssh clients
    '/usr/bin/scp': ;
    '/usr/bin/sftp': ;
    '/usr/bin/slogin': ;
    '/usr/bin/ssh': ;
    '/usr/bin/ssh-add': ;
    '/usr/bin/ssh-agent': ;
    '/usr/bin/ssh-copy-id': ;
    '/usr/bin/ssh-keyscan': ;
  }
}
