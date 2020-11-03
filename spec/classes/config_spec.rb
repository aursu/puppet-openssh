require 'spec_helper'

describe 'openssh::config' do
  let(:pre_condition) do
    <<-PRECOND
    class { 'openssh': }
    PRECOND
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      context 'check sshd config' do
        it {
          is_expected.to contain_file('/etc/ssh/sshd_config')
            .with_content(%r{Port 22})
          is_expected.to contain_file('/etc/ssh/sshd_config')
            .with_content(%r{PermitRootLogin without-password})
          is_expected.to contain_file('/etc/ssh/sshd_config')
            .with_content(%r{StrictModes yes})
          is_expected.to contain_file('/etc/ssh/sshd_config')
            .with_content(%r{GSSAPIAuthentication yes})
          is_expected.to contain_file('/etc/ssh/sshd_config')
            .with_content(%r{AllowTcpForwarding no})
          is_expected.to contain_file('/etc/ssh/sshd_config')
            .with_content(%r{Banner none})
          is_expected.to contain_file('/etc/ssh/sshd_config')
            .with_content(%r{AuthorizedKeysFile .ssh/authorized_keys})
        }
      end

      context 'when setup host keys' do
        let(:params) do
          {
            setup_host_key: true,
          }
        end

        it {
          is_expected.to contain_file('/etc/ssh/sshd_config')
            .with_content(%r{HostKey /etc/ssh/ssh_host_rsa_key})
        }

        it {
          is_expected.to contain_file('/etc/ssh/sshd_config')
            .with_content(%r{HostKey /etc/ssh/ssh_host_ecdsa_key})
        }

        if ['centos-7-x86_64', 'centos-8-x86_64'].include?(os)
          it {
            is_expected.to contain_file('/etc/ssh/sshd_config')
              .with_content(%r{HostKey /etc/ssh/ssh_host_ed25519_key})
          }
        end
      end

      context 'check UsePrivilegeSeparation is set properly' do
        it { is_expected.to contain_file('/etc/ssh/sshd_config') }

        case os
        when 'centos-6-x86_64'
          it {
            is_expected.to contain_file('/etc/ssh/sshd_config')
              .with_content(%r{UsePrivilegeSeparation yes})
          }
        when 'centos-7-x86_64'
          it {
            is_expected.to contain_file('/etc/ssh/sshd_config')
              .with_content(%r{UsePrivilegeSeparation sandbox})
          }
        else
          it {
            is_expected.not_to contain_file('/etc/ssh/sshd_config')
              .with_content(%r{UsePrivilegeSeparation})
          }
        end
      end

      context 'check Protocol is set properly' do
        it { is_expected.to contain_file('/etc/ssh/sshd_config') }

        case os
        when 'centos-6-x86_64'
          it {
            is_expected.to contain_file('/etc/ssh/sshd_config')
              .with_content(%r{Protocol 2})
          }
        else
          it {
            is_expected.not_to contain_file('/etc/ssh/sshd_config')
              .with_content(%r{Protocol})
          }
        end
      end
    end
  end
end
