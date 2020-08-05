require 'spec_helper'

describe 'openssh::package' do
  let(:pre_condition) do
    <<-PRECOND
    class {'openssh': }
    PRECOND
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      context 'check client package management' do
        let(:params) do
          {
            'manage_client' => true,
          }
        end

        it {
          is_expected.to contain_package('openssh-clients')
            .with_ensure('present')
        }
      end

      context 'check server package management' do
        let(:params) do
          {
            'manage_server' => true,
          }
        end

        it {
          is_expected.to contain_package('openssh-server')
            .with_ensure('present')
        }

        if ['redhat-7-x86_64', 'centos-7-x86_64'].include?(os)
          it {
            is_expected.to contain_package('initscripts')
              .with_ensure('present')
          }
        end
      end
    end
  end
end
