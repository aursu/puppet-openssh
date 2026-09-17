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

      socket_unit = (os_facts[:os]['family'] == 'Debian') ? 'ssh.socket' : 'sshd.socket'
      # Matches the manifest: sha256('openssh::service')[0,7]
      socket_exec = "restart-#{socket_unit}-1b7dac3"

      it { is_expected.to compile }

      context 'check service with default parameters' do
        let(:params) do
          {}
        end

        case os_facts[:os]['family']
        when 'Debian'
          it {
            is_expected.to contain_service('ssh')
              .with_ensure('running')
              .with_enable(true)
          }
        else
          it {
            is_expected.to contain_service('sshd')
              .with_ensure('running')
              .with_enable(true)
          }
        end
      end

      if os.start_with?('rocky-8')
        context 'check service with default parameters' do
          it {
            is_expected.to contain_file('/etc/systemd/system/sshd.service.d/override.conf')
              .with_content(%r{^Restart=always$})
              .with_content(%r{^RestartSec=30$})
              .with_content(%r{^StartLimitInterval=0$})
          }
        end
      end

      # Socket activation. sshd does not bind on such a host - systemd does,
      # from addresses sshd-socket-generator derives from sshd_config - so the
      # reload has to re-run the generator and the socket has to restart to
      # bind what it wrote.
      context 'socket handling by default' do
        it { is_expected.to compile }

        it { is_expected.to contain_class('bsys::systemctl::daemon_reload') }

        # Guarded at apply time by is-enabled rather than at compile time by a
        # fact, so a first run on a new host is already correct and a host
        # without socket activation is a no-op.
        it {
          is_expected.to contain_exec(socket_exec)
            .with_command("systemctl restart #{socket_unit}")
            .with_onlyif("systemctl is-enabled #{socket_unit}")
            .with_refreshonly(true)
        }

        # Reload first, restart second. Reversed, the socket rebinds onto the
        # fragment the generator has not rewritten yet.
        it {
          is_expected.to contain_class('bsys::systemctl::daemon_reload')
            .that_notifies("Exec[#{socket_exec}]")
        }
      end

      context 'when manage_socket is false' do
        let(:params) { { manage_socket: false } }

        it { is_expected.to compile }
        it { is_expected.not_to contain_exec(socket_exec) }
      end
    end
  end
end
