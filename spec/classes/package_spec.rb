require 'spec_helper'

describe 'openssh::package' do
  let(:pre_condition) do
    <<-PRECOND
    class { 'openssh': }
    PRECOND
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      if ['rocky-8-x86_64', 'centos-8-x86_64'].include?(os)
        it {
          is_expected.to contain_package('openssh')
            .with_provider('dnf')
        }
      else
        it {
          is_expected.to contain_package('openssh')
            .with_ensure('installed')
            .with_provider('yum')
        }
      end

      context 'check client package management' do
        let(:params) do
          {
            'manage_client' => true,
          }
        end

        it {
          is_expected.to contain_package('openssh-clients')
            .with_ensure('installed')
        }

        context 'and custom repo is added for dependencies' do
          let(:params) do
            super().merge(
              'install_options' => [{ '--enablerepo' => 'corp' }],
            )
          end
  
  
          it {
            is_expected.to contain_package('openssh-clients')
              .with('install_options' => [{ '--enablerepo' => 'corp' }])
          }
        end
      end

      context 'check server package management' do
        let(:params) do
          {
            'manage_server' => true,
          }
        end

        it {
          is_expected.to contain_package('openssh-server')
            .with_ensure('installed')
        }

        if ['redhat-7-x86_64', 'centos-7-x86_64'].include?(os)
          it {
            is_expected.to contain_package('initscripts')
              .with_ensure('present')
          }
        end

        context 'check dependencies management' do
          let(:pre_condition) do
            <<-PRECOND
            class { 'openssh':
              server_dependencies => [],
            }
            PRECOND
          end

          if ['redhat-7-x86_64', 'centos-7-x86_64'].include?(os)
            it {
              is_expected.not_to contain_package('initscripts')
            }
          end
        end
      end
    end
  end
end
