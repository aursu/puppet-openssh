require 'spec_helper'

describe 'openssh::ssh_keygen' do
  let(:pre_condition) do
    <<-PRECOND
    class {'openssh': }
    PRECOND
  end

  let(:params) do
    {
      'sshkey_name' => 'root@stype',
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts.merge(
          'sshpubkey_root' => ['ssh-rsa', 'AAAAB3NzaC1yc2EAAAADAQABAAABAQD5shIL', 'root@stype'],
        )
      end

      it { is_expected.to compile }

      context 'check ssh_authorized_key exported resource' do
        it {
          expect(exported_resources).to contain_ssh_authorized_key('root@stype')
            .with(
              'ensure' => 'present',
              'key' => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQD5shIL',
              'user' => 'root',
              'target' => '/root/.ssh/authorized_keys',
              'options' => [],
              'type' => 'ssh-rsa',
            )
          is_expected.not_to contain_exec('ssh_keygen-root')
        }
      end

      context 'check sshkey_generate_enable set to true' do
        let(:params) do
          super().merge(
            'sshkey_generate_enable' => true,
          )
        end

        it {
          is_expected.to contain_exec('ssh_keygen-root')
            .with(
              'command' => "ssh-keygen -t rsa -b 2048 -f \"/root/.ssh/id_rsa\" -N '' -C \"root@stype\"",
              'user' => 'root',
              'creates' => '/root/.ssh/id_rsa',
            )
        }
      end

      context 'when global Hiera in use' do
        let(:pre_condition) do
          <<-PRECOND
          class {'openssh': }
          class {'openssh::keys': }
          PRECOND
        end
        let(:params) do
          {
          }
        end

        context 'when openssh::keys::sshkey_name is set' do
          let(:facts) do
            os_facts.merge(
              'sshpubkey_root' => ['ssh-dss', 'AAAAB3NzaC1yc2EAAAADAQABAAABAQD5shIL', 'root@stype2host'],
              'stype' => 'stype2',
            )
          end

          it {
            expect(exported_resources).to contain_ssh_authorized_key('root@stype2host')
              .with(
                'ensure' => 'present',
                'key' => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQD5shIL',
                'user' => 'root',
                'target' => '/root/.ssh/authorized_keys',
                'options' => [],
                'type' => 'ssh-dss',
              )
          }
        end

        context 'when openssh::keys::sshkey_type is set' do
          let(:facts) do
            os_facts.merge(
              'sshpubkey_root' => ['ssh-dss', 'AAAAB3NzaC1yc2EAAAADAQABAAABAQD5shIL', 'root@stype3host'],
              'stype' => 'stype3',
            )
          end

          it {
            expect(exported_resources).to contain_ssh_authorized_key('root@stype3host')
              .with(
                'ensure' => 'present',
                'key' => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQD5shIL',
                'user' => 'root',
                'target' => '/etc/ssh/authorized_keys',
                'options' => [],
                'type' => 'ssh-dss',
              )
          }
        end

        context 'when differebt user' do
          let(:facts) do
            os_facts.merge(
              'sshpubkey_root' => ['ssh-rsa', 'AAAAB3NzaC1yc2EAAAADAQABAAABAQD5shIL', 'root@stype4host'],
              'stype' => 'stype4',
            )
          end

          it {
            expect(exported_resources).not_to contain_ssh_authorized_key('root@stype4host')
          }
        end
      end
    end
  end
end
