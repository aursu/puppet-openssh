require 'spec_helper'

describe 'openssh::keys' do
  let(:pre_condition) do
    <<-PRECOND
    class { 'openssh': }
    PRECOND
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      context 'check sshkey_dir directory' do
        it {
          is_expected.to contain_file('/root/.ssh')
            .with_ensure('directory')
            .with(
              'group' => 'root',
              'owner' => 'root',
            )
        }
      end

      context 'check authorized keys setup' do
        let(:facts) do
          os_facts.merge(
            'stype' => 'stype5',
          )
        end

        it {
          is_expected.to contain_file('/root/.ssh/authorized_keys')
            .with_content(%r{^ssh-rsa AAAAB3NzaC1yc2EAAAABI.*7UU4ecXSz2FMFlfxCU8lbXezMA8fpU= root@host1$})
        }

        it {
          is_expected.to contain_file('/root/.ssh/authorized_keys')
            .with_content(%r{^ssh-rsa AAAAB3NzaC1yc2EAAAABI.*aiaGqpo0PzElJlFUa/kQJqH8XypkBYrzSQ== root@host2$})
        }

        it {
          is_expected.to contain_file('/root/.ssh/authorized_keys')
            .with_content(%r{^ssh-rsa AAAAB3NzaC1yc2EAAAABI.*g0SRN5054sE971E3fOylM2k0uXqjlbdqCyRbLaC85zYw== root@host3$})
        }

        it {
          expect(exported_resources).to contain_sshkey('securehost.securedomain_root_known_hosts_ecdsa')
            .with(
              'host_aliases' => ['securehost', 'securehost.securedomain', '172.16.254.254'],
              'key'          => 'AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBLzznbPhkm2Gvm8nDxINPImVpYU94Te4X8v5NP7lntGjth/NocvYmX9Yw99Nu0JAlD3l94PHfXHLpVelUQa4nGo=',
              'target'       => '/root/.ssh/known_hosts',
              'type'         => 'ecdsa-sha2-nistp256',
              'tag'          => ['sshkey'],
            )
        }

        it {
          expect(exported_resources).to contain_sshkey('securehost.securedomain_root_known_hosts_ed25519')
            .with(
              'host_aliases' => ['securehost', 'securehost.securedomain', '172.16.254.254'],
              'key'          => 'AAAAC3NzaC1lZDI1NTE5AAAAIMhF9WDnRBzWaZSuAy2KUmDbcn0Qq7jgPruGLE+7bfdj',
              'target'       => '/root/.ssh/known_hosts',
              'type'         => 'ssh-ed25519',
              'tag'          => ['sshkey'],
            )
        }

        context 'check export_tags_extra and sshkey_export_tag' do
          let(:params) do
            {
              'sshkey_export_tag' => 'webserver',
              'export_tags_extra' => ['c50', 'web'],
            }
          end

          it {
            expect(exported_resources).to contain_sshkey('securehost.securedomain_root_known_hosts_ecdsa')
              .with(
                'host_aliases' => ['securehost', 'securehost.securedomain', '172.16.254.254'],
                'key'          => 'AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBLzznbPhkm2Gvm8nDxINPImVpYU94Te4X8v5NP7lntGjth/NocvYmX9Yw99Nu0JAlD3l94PHfXHLpVelUQa4nGo=',
                'target'       => '/root/.ssh/known_hosts',
                'type'         => 'ecdsa-sha2-nistp256',
                'tag'          => ['webserver', 'c50', 'web'],
              )
          }
        end
      end

      context 'check custom_ssh_keys setup' do
        let(:facts) do
          os_facts.merge(
            'stype' => 'stype8',
          )
        end

        it {
          is_expected.to contain_file('/root/.ssh/authorized_keys')
            .with_content(%r{^ssh-rsa AAAAB3NzaC1yc2EAAAABI.*7UU4ecXSz2FMFlfxCU8lbXezMA8fpU= root@host1$})
        }

        it {
          is_expected.to contain_file('/root/.ssh/authorized_keys')
            .with_content(%r{^ssh-rsa AAAAB3NzaC1yc2EAAAABI.*aiaGqpo0PzElJlFUa/kQJqH8XypkBYrzSQ== root@host2$})
        }

        it {
          is_expected.to contain_file('/root/.ssh/authorized_keys')
            .with_content(%r{^ssh-rsa AAAAB3NzaC1yc2EAAAABI.*g0SRN5054sE971E3fOylM2k0uXqjlbdqCyRbLaC85zYw== root@host3$})
        }
      end

      context 'check sshkey_name propagation' do
        # rubocop:disable Metrics/LineLength
        let(:sshkey) { 'AAAAB3NzaC1yc2EAAAADAQABAAABAQC728q/0r0BAdDbWp4gjCsW4NxcLFSj5sFZOPSsNLw6eNdaUKZnJsvSvX7IhwY/suuolzHY+x0OLPerOvhZrrviM2HX3PlY29QLuY2wVDYw7Z10n1v8Q0//xLU1oskfINfbjFWxklhxQZ8+jsJGZYkHtSmkHxR1srYmTg+nmoczxyg+bRMzE8BDXOQBwvFIC9uygH5eI35f/GFk5ycUUaG8j3V53YxzrUkK0JBxbCr9plN2L79sQuCj9yRgDLVZE1B2p92f+z07Mk3ytye8Twe248DLtqqvk5ZsjLHR9q5LcHRhMqMaczexEq7Y9QFjl5oeyfONxiGrmTl5hvDpfA+N' }
        # rubocop:enable Metrics/LineLength
        let(:params) do
          {
            'sshkey' => sshkey,
          }
        end

        it {
          is_expected.to contain_exec('mkdir /root/.ssh for root@securehost')
        }

        it {
          is_expected.to contain_ssh_authorized_key('root@securehost')
            .with_key(sshkey)
            .with_ensure('present')
            .with_user('root')
            .with_type('ssh-rsa')
            .with_target('/root/.ssh/authorized_keys')
            .with_options([])
        }

        it {
          is_expected.to contain_ssh_authorized_key('root@securehost')
            .that_requires('Exec[mkdir /root/.ssh for root@securehost]')
        }

        it {
          expect(exported_resources).to contain_sshkey('securehost.securedomain_root_known_hosts_ecdsa')
            .with(
              'host_aliases' => ['securehost', 'securehost.securedomain', '172.16.254.254'],
              'key'          => 'AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBLzznbPhkm2Gvm8nDxINPImVpYU94Te4X8v5NP7lntGjth/NocvYmX9Yw99Nu0JAlD3l94PHfXHLpVelUQa4nGo=',
              'target'       => '/root/.ssh/known_hosts',
              'type'         => 'ecdsa-sha2-nistp256',
              'tag'          => ['sshkey', 'root_known_hosts', 'ecdsa'],
            )
        }

        it {
          expect(exported_resources).to contain_sshkey('securehost.securedomain_root_known_hosts_ed25519')
            .with(
              'host_aliases' => ['securehost', 'securehost.securedomain', '172.16.254.254'],
              'key'          => 'AAAAC3NzaC1lZDI1NTE5AAAAIMhF9WDnRBzWaZSuAy2KUmDbcn0Qq7jgPruGLE+7bfdj',
              'target'       => '/root/.ssh/known_hosts',
              'type'         => 'ssh-ed25519',
              'tag'          => ['sshkey', 'root_known_hosts', 'ed25519'],
            )
        }

        context 'check export_tags_extra and sshkey_export_tag' do
          let(:params) do
            {
              'sshkey'            => sshkey,
              'sshkey_export_tag' => 'webserver',
              'export_tags_extra' => ['c50', 'web'],
            }
          end

          it {
            expect(exported_resources).to contain_sshkey('securehost.securedomain_root_known_hosts_ecdsa')
              .with(
                'host_aliases' => ['securehost', 'securehost.securedomain', '172.16.254.254'],
                'key'          => 'AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBLzznbPhkm2Gvm8nDxINPImVpYU94Te4X8v5NP7lntGjth/NocvYmX9Yw99Nu0JAlD3l94PHfXHLpVelUQa4nGo=',
                'target'       => '/root/.ssh/known_hosts',
                'type'         => 'ecdsa-sha2-nistp256',
                'tag'          => ['webserver', 'root_known_hosts', 'ecdsa', 'c50', 'web'],
              )
          }
        end
      end
    end
  end
end
