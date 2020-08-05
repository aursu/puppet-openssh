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
    end
  end
end