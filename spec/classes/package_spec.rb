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

      case os_facts[:os]['family']
      when 'RedHat'
        if os_facts[:os]['release']['major'] in ['6', '7']
          it {
            is_expected.to contain_package('openssh')
              .with_ensure('installed')
              .with_provider('yum')
          }
        else
          it {
            is_expected.to contain_package('openssh')
              .with_provider('dnf')
          }
        end
      when 'Debian'
        it {
          is_expected.to contain_package('ssh')
            .with_ensure('installed')
            .without_provider
        }
      end

      context 'check client package management' do
        let(:params) do
          {
            'manage_client' => true,
          }
        end

        case os_facts[:os]['family']
        when 'RedHat'
          it {
            is_expected.to contain_package('openssh-clients')
              .with_ensure('installed')
          }
        when 'Debian'
          it {
            is_expected.to contain_package('openssh-client')
              .with_ensure('installed')
              .without_provider
          }
        end

        context 'and custom repo is added for dependencies' do
          let(:params) do
            super().merge(
              'install_options' => [{ '--enablerepo' => 'corp' }],
            )
          end

          case os_facts[:os]['family']
          when 'RedHat'
            it {
              is_expected.to contain_package('openssh-clients')
                .with('install_options' => [{ '--enablerepo' => 'corp' }])
            }
          when 'Debian'
            it {
              is_expected.to contain_package('openssh-client')
                .with('install_options' => [{ '--enablerepo' => 'corp' }])
                .without_provider
            }
          end
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

        if os_facts[:os]['family'] == 'RedHat' && os_facts[:os]['release']['major'] == '7'
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

          if os_facts[:os]['family'] == 'RedHat' && os_facts[:os]['release']['major'] == '7'
            it {
              is_expected.not_to contain_package('initscripts')
            }
          end
        end
      end
    end
  end
end
