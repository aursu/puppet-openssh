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
        let(:params) do
          {
          }
        end
        let(:facts) do
          os_facts.merge(
            'stype' => 'stype5',
          )
        end

        it {
          is_expected.to contain_file('/root/.ssh/authorized_keys')
            .with_content(%r{^ssh-rsa AAAAB3NzaC1yc2EAAAABI.*7UU4ecXSz2FMFlfxCU8lbXezMA8fpU= root@host1$})

          is_expected.to contain_file('/root/.ssh/authorized_keys')
            .with_content(%r{^ssh-rsa AAAAB3NzaC1yc2EAAAABI.*aiaGqpo0PzElJlFUa/kQJqH8XypkBYrzSQ== root@host2$})

          is_expected.to contain_file('/root/.ssh/authorized_keys')
            .with_content(%r{^ssh-rsa AAAAB3NzaC1yc2EAAAABI.*g0SRN5054sE971E3fOylM2k0uXqjlbdqCyRbLaC85zYw== root@host3$})
        }
      end
    end
  end
end
