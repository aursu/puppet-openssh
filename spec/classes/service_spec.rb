require 'spec_helper'

describe 'openssh::service' do
  let(:pre_condition) do
    <<-PRECOND
    class { 'openssh': }
    PRECOND
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      context 'check service with default parameters' do
        let(:params) do
          {}
        end

        it {
          is_expected.to contain_service('sshd')
            .with_ensure('running')
            .with_enable(true)
        }
      end

      if ['redhat-7-x86_64', 'centos-7-x86_64'].include?(os)
        context 'check service with default parameters' do
          it {
            is_expected.to contain_file('/etc/systemd/system/sshd.service.d/override.conf')
              .with_content(%r{^Restart=always$})
              .with_content(%r{^RestartSec=30$})
              .with_content(%r{^StartLimitInterval=0$})
          }
        end
      end
    end
  end
end
