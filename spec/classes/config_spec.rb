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

        context 'when ed25519 key is not activated' do
          let(:params) do
            {
              setup_host_key: true,
              setup_ed25519_key: false,
            }
          end

          if ['centos-7-x86_64', 'centos-8-x86_64'].include?(os)
            it {
              is_expected.to contain_file('/etc/ssh/sshd_config')
                .without_content(%r{ssh_host_ed25519_key})
            }
          end
        end
      end

      context 'when HostKeyAlgorithms are specified' do
        let(:params) do
          {
            hostkeyalgorithms: ['ssh-ed25519', 'ecdsa-sha2-nistp384'],
          }
        end

        it {
          is_expected.to contain_file('/etc/ssh/sshd_config')
            .with_content(%r{^HostKeyAlgorithms ssh-ed25519,ecdsa-sha2-nistp384$})
        }
      end

      context 'when MaxStartups is not specified (default)' do
        it {
          is_expected.to contain_file('/etc/ssh/sshd_config')
            .without_content(%r{^MaxStartups})
        }
      end

      context 'when MaxStartups is specified with valid values' do
        let(:params) do
          {
            max_startups: [10, 30, 60],
          }
        end

        it {
          is_expected.to contain_file('/etc/ssh/sshd_config')
            .with_content(%r{^MaxStartups 10:30:60$})
        }
      end

      context 'when MaxStartups is specified with another valid set' do
        let(:params) do
          {
            max_startups: [5, 50, 100],
          }
        end

        it {
          is_expected.to contain_file('/etc/ssh/sshd_config')
            .with_content(%r{^MaxStartups 5:50:100$})
        }
      end

      context 'when MaxSessions is not specified (default)' do
        it {
          is_expected.to contain_file('/etc/ssh/sshd_config')
            .with_content(%r{^MaxSessions 5$})
        }
      end

      context 'when MaxSessions is specified with valid value' do
        let(:params) do
          {
            max_sessions: 10,
          }
        end

        it {
          is_expected.to contain_file('/etc/ssh/sshd_config')
            .with_content(%r{^MaxSessions 10$})
        }
      end

      context 'when MaxSessions is specified with another valid value' do
        let(:params) do
          {
            max_sessions: 100,
          }
        end

        it {
          is_expected.to contain_file('/etc/ssh/sshd_config')
            .with_content(%r{^MaxSessions 100$})
        }
      end

      context 'when UseDNS is not specified (default)' do
        it {
          is_expected.to contain_file('/etc/ssh/sshd_config')
            .with_content(%r{^UseDNS no$})
        }
      end

      context 'when UseDNS is set to yes (boolean true)' do
        let(:params) do
          {
            use_dns: true,
          }
        end

        it {
          is_expected.to contain_file('/etc/ssh/sshd_config')
            .with_content(%r{^UseDNS yes$})
        }
      end

      context 'when UseDNS is set to yes (string)' do
        let(:params) do
          {
            use_dns: 'yes',
          }
        end

        it {
          is_expected.to contain_file('/etc/ssh/sshd_config')
            .with_content(%r{^UseDNS yes$})
        }
      end

      context 'when UseDNS is set to no (boolean false)' do
        let(:params) do
          {
            use_dns: false,
          }
        end

        it {
          is_expected.to contain_file('/etc/ssh/sshd_config')
            .with_content(%r{^UseDNS no$})
        }
      end

      context 'when UseDNS is set to no (string)' do
        let(:params) do
          {
            use_dns: 'no',
          }
        end

        it {
          is_expected.to contain_file('/etc/ssh/sshd_config')
            .with_content(%r{^UseDNS no$})
        }
      end

      # Any sshd_config change reloads the systemd manager, because that is
      # what re-runs sshd-socket-generator. Notified on every change, not on
      # ListenAddress alone - the generator reads Port too.
      context 'sshd_config notifies the systemd reload' do
        it { is_expected.to contain_class('bsys::systemctl::daemon_reload') }

        it {
          is_expected.to contain_file('/etc/ssh/sshd_config')
            .that_notifies('Class[bsys::systemctl::daemon_reload]')
        }
      end

      context 'when ListenAddress is not specified (default)' do
        # The wildcard bind is sshd's own default, and staying on it is what
        # every existing consumer of this module already has. Assert the
        # commented lines survive, so an upgrade cannot silently start
        # restricting where sshd listens.
        it {
          is_expected.to contain_file('/etc/ssh/sshd_config')
            .with_content(%r{^#ListenAddress 0\.0\.0\.0$})
          is_expected.to contain_file('/etc/ssh/sshd_config')
            .with_content(%r{^#ListenAddress ::$})
          is_expected.to contain_file('/etc/ssh/sshd_config')
            .without_content(%r{^ListenAddress})
        }
      end

      context 'when ListenAddress is a single IPv4 address' do
        let(:params) do
          {
            listen_address: ['10.100.16.12'],
          }
        end

        it {
          is_expected.to contain_file('/etc/ssh/sshd_config')
            .with_content(%r{^ListenAddress 10\.100\.16\.12$})
        }

        # The commented defaults must go: leaving them is harmless to sshd but
        # tells a reader the host is still on the wildcard when it is not.
        it {
          is_expected.to contain_file('/etc/ssh/sshd_config')
            .without_content(%r{^#ListenAddress})
        }
      end

      context 'when ListenAddress has several addresses' do
        let(:params) do
          {
            listen_address: ['10.100.16.12', '10.100.17.12'],
          }
        end

        # sshd takes one directive per address rather than a joined list, so
        # each entry has to render on its own line.
        it {
          is_expected.to contain_file('/etc/ssh/sshd_config')
            .with_content(%r{^ListenAddress 10\.100\.16\.12$})
          is_expected.to contain_file('/etc/ssh/sshd_config')
            .with_content(%r{^ListenAddress 10\.100\.17\.12$})
        }
      end

      context 'when ListenAddress is IPv6' do
        let(:params) do
          {
            listen_address: ['::1', '2001:db8::1'],
          }
        end

        it {
          is_expected.to contain_file('/etc/ssh/sshd_config')
            .with_content(%r{^ListenAddress ::1$})
          is_expected.to contain_file('/etc/ssh/sshd_config')
            .with_content(%r{^ListenAddress 2001:db8::1$})
        }
      end
    end
  end

  context 'validation tests for max_startups parameter' do
    let(:facts) do
      {
        os: {
          family: 'RedHat',
          name: 'CentOS',
          release: {
            major: '7',
          },
        },
      }
    end

    context 'when MaxStartups contains invalid string value' do
      let(:params) do
        {
          max_startups: [10, '', 0],
        }
      end

      it { is_expected.to compile.and_raise_error(%r{expects an Integer value}) }
    end

    context 'when MaxStartups contains invalid rate > 100' do
      let(:params) do
        {
          max_startups: [10, 150, 60],
        }
      end

      it { is_expected.to compile.and_raise_error(%r{expects an Integer\[0, 100\]}) }
    end

    context 'when MaxStartups has full value less than start value' do
      let(:params) do
        {
          max_startups: [60, 30, 10],
        }
      end

      it { is_expected.to compile.and_raise_error(%r{MaxStartups: 'full' value \(10\) must be >= 'start' value \(60\)}) }
    end

    context 'when MaxStartups has wrong array size (too few elements)' do
      let(:params) do
        {
          max_startups: [10, 30],
        }
      end

      it { is_expected.to compile.and_raise_error(%r{expects size to be 3, got 2}) }
    end

    context 'when MaxStartups has wrong array size (too many elements)' do
      let(:params) do
        {
          max_startups: [10, 30, 60, 100],
        }
      end

      it { is_expected.to compile.and_raise_error(%r{expects size to be 3, got 4}) }
    end

    context 'when MaxStartups is a string instead of array' do
      let(:params) do
        {
          max_startups: '10:30:60',
        }
      end

      it { is_expected.to compile.and_raise_error(%r{expects a value of type Undef or Tuple, got String}) }
    end

    context 'when MaxStartups is explicitly set to undef' do
      let(:params) do
        {
          max_startups: :undef,
        }
      end

      it { is_expected.to compile }

      it {
        is_expected.to contain_file('/etc/ssh/sshd_config')
          .without_content(%r{^MaxStartups})
      }
    end

    context 'when MaxSessions is zero' do
      let(:params) do
        {
          max_sessions: 0,
        }
      end

      it { is_expected.to compile.and_raise_error(%r{expects an Integer\[1\] value}) }
    end

    context 'when MaxSessions is negative' do
      let(:params) do
        {
          max_sessions: -5,
        }
      end

      it { is_expected.to compile.and_raise_error(%r{expects an Integer\[1\] value, got Integer\[-5}) }
    end

    context 'when MaxSessions is a string' do
      let(:params) do
        {
          max_sessions: '10',
        }
      end

      it { is_expected.to compile.and_raise_error(%r{expects an Integer}) }
    end

    context 'when UseDNS is an invalid string' do
      let(:params) do
        {
          use_dns: 'maybe',
        }
      end

      it { is_expected.to compile.and_raise_error(%r{expects an Openssh::Switch = Variant\[Boolean, Enum\['no', 'yes'\]\] value, got String}) }
    end

    context 'when UseDNS is an invalid type' do
      let(:params) do
        {
          use_dns: 123,
        }
      end

      it { is_expected.to compile.and_raise_error(%r{expects an Openssh::Switch = Variant\[Boolean, Enum\['no', 'yes'\]\] value, got Integer}) }
    end

    # ListenAddress is a lockout-class parameter: sshd binds only what is
    # listed and refuses to start on a malformed entry, so the type has to
    # reject bad input at catalogue time rather than at service start.
    context 'when ListenAddress carries a prefix length' do
      let(:params) do
        {
          listen_address: ['10.100.16.12/26'],
        }
      end

      # The likeliest mistake by far, because the value is usually copied from
      # an interface definition or `ip addr`, both of which write CIDR. sshd
      # rejects it and then will not start at all.
      it { is_expected.to compile.and_raise_error(%r{index 0 expects a Stdlib::IP::Address::Nosubnet}) }
    end

    context 'when ListenAddress is not an address' do
      let(:params) do
        {
          listen_address: ['not-an-address'],
        }
      end

      it { is_expected.to compile.and_raise_error(%r{index 0 expects a Stdlib::IP::Address::Nosubnet}) }
    end

    context 'when ListenAddress is a bare string instead of an array' do
      let(:params) do
        {
          listen_address: '10.100.16.12',
        }
      end

      it { is_expected.to compile.and_raise_error(%r{expects a value of type Undef or Array, got String}) }
    end

    context 'when ListenAddress is an empty array' do
      let(:params) do
        {
          listen_address: [],
        }
      end

      # An empty array would render no directives at all, which is
      # indistinguishable from undef but reads like an intent to restrict.
      # Rejecting it keeps "no ListenAddress" spelled exactly one way.
      it { is_expected.to compile.and_raise_error(%r{expects size to be at least 1, got 0}) }
    end

    context 'when ListenAddress is explicitly set to undef' do
      let(:params) do
        {
          listen_address: :undef,
        }
      end

      it { is_expected.to compile }

      it {
        is_expected.to contain_file('/etc/ssh/sshd_config')
          .with_content(%r{^#ListenAddress 0\.0\.0\.0$})
      }
    end
  end
end
