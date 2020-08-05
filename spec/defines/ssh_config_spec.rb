require 'spec_helper'

describe 'openssh::ssh_config' do
  let(:title) { 'root' }
  let(:params) do
    {
      'ssh_config' => [],
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with user root and empty ssh_config' do
        it { is_expected.to compile }

        it {
          is_expected.not_to contain_exec('create /root/.ssh/config path')
          is_expected.not_to contain_exec('create /etc/ssh/ssh_config path')
        }

        it {
          is_expected.not_to contain_file('/root/.ssh/config')
          is_expected.not_to contain_file('/etc/ssh/ssh_config')
        }
      end

      context 'with user root and single Host config' do
        let(:params) do
          super().merge(
            'ssh_config' => [{
              'Host' => ['serv1.domain.tld', 'serv3.domain.tld', 'serv1', 'serv3'],
              'ControlPath' => '~/.ssh/master-%r@%h:%p',
              'ControlMaster' => 'auto',
            }],
          )
        end

        it {
          is_expected.to contain_exec('create /root/.ssh/config path')
            .with_command('mkdir -p /root/.ssh')
            .with_user('root')
        }

        it {
          is_expected.to contain_file('/root/.ssh/config')
            .with_content(%r{^Host serv1.domain.tld serv3.domain.tld serv1 serv3$})
            .with_content(%r{^\s+ControlPath ~/.ssh/master-%r@%h:%p$})
            .with_content(%r{^\s+ControlMaster auto$})
            .with_owner('root')
            .with_group('root')
            .with_mode('0600')
            .that_requires('Exec[create /root/.ssh/config path]')
        }
      end

      context 'with global options' do
        let(:params) do
          super().merge(
            'ssh_config' => [
              {
                'Host' => ['serv1.domain.tld', 'serv3.domain.tld', 'serv1', 'serv3'],
                'ControlPath' => '~/.ssh/master-%r@%h:%p',
                'ControlMaster' => 'auto',
              },
              {
                'ServerAliveInterval' => 30,
                'ServerAliveCountMax' => 1200,
                'LogLevel' => 'ERROR',
              },
            ],
          )
        end

        it {
          is_expected.to contain_file('/root/.ssh/config')
            .with_content(%r{^ServerAliveInterval 30$})
            .with_content(%r{^ServerAliveCountMax 1200$})
            .with_content(%r{^LogLevel ERROR$})
        }

        it {
          is_expected.to contain_file('/root/.ssh/config')
            .with_content(%r{^Host serv1.domain.tld serv3.domain.tld serv1 serv3$})
            .with_content(%r{^\s+ControlPath ~/.ssh/master-%r@%h:%p$})
            .with_content(%r{^\s+ControlMaster auto$})
        }
      end

      context 'with global options mixed' do
        let(:params) do
          super().merge(
            'ssh_config' => [
              {
                'Host' => ['serv1.domain.tld', 'serv3.domain.tld', 'serv1', 'serv3'],
                'ControlPath' => '~/.ssh/master-%r@%h:%p',
                'ControlMaster' => 'auto',
              },
              {
                'ServerAliveInterval' => 30,
                'ServerAliveCountMax' => 1200,
                'LogLevel' => 'ERROR',
              },
              {
                'Host' => 'gitlab1.corp.domain.tld',
                'IdentityFile' => '~/.ssh/gitlab.id_rsa',
              },
              {
                'ServerAliveInterval' => 120,
                'LogLevel' => 'INFO',
                'Port' => 3389,
              },
            ],
          )
        end

        it {
          is_expected.to contain_file('/root/.ssh/config')
            .with_content(%r{^ServerAliveInterval 120$})
            .with_content(%r{^ServerAliveCountMax 1200$})
            .with_content(%r{^LogLevel INFO$})
            .with_content(%r{^Port 3389$})
        }

        it {
          is_expected.to contain_file('/root/.ssh/config')
            .with_content(%r{^Host b1.domain.tld serv3.domain.tld b1 serv3$})
            .with_content(%r{^\s+ControlPath ~/.ssh/master-%r@%h:%p$})
            .with_content(%r{^\s+ControlMaster auto$})
        }

        it {
          is_expected.to contain_file('/root/.ssh/config')
            .with_content(%r{^Host gitlab1.corp.domain.tld$})
            .with_content(%r{^\s+IdentityFile ~/.ssh/gitlab.id_rsa$})
        }
      end

      context 'with system wide options' do
        let(:params) do
          super().merge(
            'ssh_config' => [
              {
                'ServerAliveInterval' => 30,
                'ServerAliveCountMax' => 1200,
                'LogLevel' => 'ERROR',
              },
            ],
            'system_wide' => true,
          )
        end

        it {
          is_expected.to contain_file('/etc/ssh/ssh_config')
            .with_content(%r{^ServerAliveInterval 30$})
            .with_content(%r{^ServerAliveCountMax 1200$})
            .with_content(%r{^LogLevel ERROR$})
            .with_mode('0644')
            .with_group('root')
        }

        it {
          is_expected.not_to contain_exec('create /root/.ssh/config path')
          is_expected.not_to contain_exec('create /etc/ssh/ssh_config path')
        }
      end
    end
  end
end
