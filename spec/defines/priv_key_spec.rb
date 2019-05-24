require 'spec_helper'

rsa_key_data = <<-'PRIVKEY'
-----BEGIN RSA PRIVATE KEY-----
MIIEpgIBAAKCAQEA2AVBmKnhEV8O7ptGsQUzIISCjKsVSzgz0zGtRvC9Mg4cpk0v
mAWFX6odIbOLFmbrtFEnKoFi9Qyae6Zs1pA7fshZYF7Y0LuWBeftuuiordTbt+vM
I3CnfVbzkilAdrUJk7g6WKMrVge/8B9FcVBrYn1hMEYABQAciC19oDR1afhVeDX3
+N84ckJk65jw8aZmJfDIc1vgpIErKkgtYgU555OgQAfc+gExEHbXlLtFDKGvsbhm
Z9YZ3VTMAvidnjO+je/yna36U6ONmj6xzYFwjzg6jaXFo0fzNSTM6NrnvKY/e+gY
Haud9E8cKF7058WN0jOegPqz0aym+c17f5/63wIDAQABAoIBAQDB0v2HcC2su4EX
YKVuIf881wiYFM2XX0dI4NLbyxfG+NiF8s2YdqO0MVvQKFvM7u3gLcyZm9xhiTx3
Y91WK7XmTPe8u32I1DeI9w/cW/M1fb7jaKQSzHrLwJ/tbiwUFt4P+AYKD+XLXErA
th5FzOV9SohQmw5bbj0rhr2oaElNmUlipjuS8tPBvqG7ONtYmqp+fNd2272wUxYx
86pU+J52wMHiEg0eX1xLDGm7peyE7gMcarr6nRwxeXJA8qSTw1mzbFA8Y2vvrgCG
DDNMVHB3IKVoU69URWfj3bGOG6CXM0gEOmqN8G2y95KVsNlfOLw5sKGYAsbEL6j+
e2NcXV9JAoGBAPCAD18wDrYyFYW0xkJjnw1d/2DmML06kJfFQIy/s1sebLzGClEe
x62PyivuYBqBOtrzxDGlgiQ9abtMjzYYMx0BOEh9maRsjRSmFI7o2PMANxAKCr0j
2JLWh9lQScdofb1TakbDBG+08q+uwz4M4iI3K7MsNhdM6U3uGy0dFXidAoGBAOXx
UCQ32WieeIeYih1rZXppSqo32yYT8PlZfCBdEY7kh70SDgYIG3wMMWkHFGqaVPog
z1suh6rEiYjZvbHn6daevJFu9lwzqGJXZCZY+yJbzoKy95YOmOvfYQKta2Hw/oxb
MwrtiDupz+X/fpfjXTv1dWDpm99EVV9voCKiFPKrAoGBAKP0SYZ09rKStkVulfJQ
g+/S8vSWOQfn0wcEfBr33UfzF+IhiIsA1tOlwQft/CpVi1AU+t11naEjFN+RM9iG
6uGNIVeZ+JI1RoCbMEy0xKH0tZUDo4qJ021XP0mRCJseywm0wjD3ZiDZVNEb7RJy
Kf91aR8+tqlvz2VHO9OnjimpAoGBALI6v3GzUHMFEkuX8sYm7ntZjaQus1DqeAfu
UoYLXYayoHvuuKv4MMWP9eSAtlSC14chU1hL0qCMwkYu8BgruFbAp0zbA14oNEY1
ks0ef1n8ay9nZP0Mx39cn6choHBECinkrsWzo7sLPrf5t7gnZacJ9TdvG4CNSNc2
gJsXosENAoGBALcgqDMS84tz6xyCzNtOdFN4PPJSEihFFr9/f8Co2O2JkIWS9d9w
tDINJRULbKZRRw7miLMOipeJy7Q282Tsa4rw1nCLLVJ60jkq0/eknfvY3lbNKHhS
j7p5zomqaI2YvdoPT+9Uh1jiG8J/fRmB7PC3Dj4ElCjYg+jUQn4qgMKr
-----END RSA PRIVATE KEY-----
PRIVKEY

dsa_key_data = <<-'PRIVKEY'
-----BEGIN DSA PRIVATE KEY-----
MIIBugIBAAKBgQCxnEakg4J/wUFJPYCR2gdEGKXFTUuFdOa6c2bq1gmyZT0KK70q
rxxzxBqy3Jmq7goney5HQL0grIoSoW+TKxiIXsDZEtpp+YOiNBKGjSVBSDBNirUc
MqJoMdXkI24Estk+BTvQ/FLD+b29Jfcfc1HTmYlAqG/hPWgcFgEuTlShIwIVAIKr
0kht1pg3W72RtTTSl4IjVcz1AoGAOiJR53q0sdVI5ToxgyFTKm9IQaIBVd6ApxCW
E90cmwpclOejGm6uF9ZE53xhUUqo45dyiqhgM8Fw99UclKc0QiSTyc+mob35grwI
y5kmnr7KTesw+9uZtxoTdOIvJl+WErxAAx6SuwpFnMiRiKnT3vdb4S4OuhQymJkL
ybRAKnMCgYBkdbKDEHC2zHisK5TGqW0RxEkiuEhOjW6Tz2XmVPx/4msp4w8odW99
fZvE8JFQV6NJ7ophfwIoUAR1WQXuZKQVD/LZ5vw2e/9CjKD9givc47wGCqqqH2BU
0K2L4azFMVSmOBjiSW4D3BhrWpMTV1uEUYXk2E1MXEYbSKoVnXAB2QIUMGgcjyiK
ObR7qGCRhfgniM3jk1Q=
-----END DSA PRIVATE KEY-----
PRIVKEY

ec_key_data = <<-'PRIVKEY'
-----BEGIN EC PRIVATE KEY-----
MIHcAgEBBEIAHLk4NKGPpKCq3LSy88vO7wceTVYFHBISKjrKDK+Yxw1YxxPB3aow
ucO4sk7IDlEcoJITvTfE6MdW33K9/6HhnE6gBwYFK4EEACOhgYkDgYYABAGMBDts
u9SJgO7Vc1azAU2GkjXzausF0hw446W0GSK0q0Mfs/ohRHBsVKiilqKz/LgjHd9S
ky2tNxJ5VvJHXcN50wHPNN62XeHBJOw+l5AAtZtChoAnOz77HgLqY8aCQt903+BM
8gVu5m027f/2UR3SstcjcKU9GAWeO66LCZXGYXFqow==
-----END EC PRIVATE KEY-----
PRIVKEY

describe 'openssh::priv_key' do
  let(:title) { 'namevar' }
  let(:params) do
    {
      'user_name' => 'root',
      'key_data'  => rsa_key_data,
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts.merge(
          'hostname' => 'web0c0',
        )
      end

      context 'with default parameters (RSA key)' do
        it { is_expected.to compile }

        it {
          is_expected.to contain_exec('create /root/.ssh/id_rsa path')
            .with_command('mkdir -p /root/.ssh')
            .with_user('root')
        }

        it {
          is_expected.to contain_file('/root/.ssh/id_rsa')
            .with_content(rsa_key_data)
            .with_owner('root')
            .with_group('root')
            .that_requires('Exec[create /root/.ssh/id_rsa path]')
        }
      end

      context 'with generating public key' do
        let(:title) { 'root@web0c0' }
        let(:params) do
          super().merge(
            'generate_public' => true,
          )
        end

        it {
          is_expected.to contain_exec('generate /root/.ssh/id_rsa.pub')
            .with_command('ssh-keygen -f /root/.ssh/id_rsa -y > /root/.ssh/id_rsa.pub')
            .with_refreshonly(true)
            .with_user('root')
            .that_subscribes_to('File[/root/.ssh/id_rsa]')
        }

        if ['redhat-7-x86_64', 'centos-7-x86_64'].include?(os)
          it {
            is_expected.to contain_exec('add /root/.ssh/id_rsa.pub comment')
              .with_command('ssh-keygen -f /root/.ssh/id_rsa -c -C root@web0c0')
              .with_refreshonly(true)
              .with_user('root')
              .that_subscribes_to('Exec[generate /root/.ssh/id_rsa.pub]')
          }
        end
      end

      context 'with incorrect key type' do
        let(:params) do
          super().merge(
            'key_data' => dsa_key_data,
          )
        end

        it { is_expected.to compile.and_raise_error(%r{Provided PEM key data is not valid for rsa key}) }
      end

      context 'with DSA key' do
        let(:title) { 'root@web0c0' }
        let(:params) do
          super().merge(
            'key_data' => dsa_key_data,
            'sshkey_type' => 'ssh-dss',
            'generate_public' => true,
          )
        end

        it { is_expected.to compile }
        it {
          is_expected.to contain_file('/root/.ssh/id_dsa')
            .with_content(dsa_key_data)
        }
        it {
          is_expected.to contain_exec('generate /root/.ssh/id_dsa.pub')
            .with_command('ssh-keygen -f /root/.ssh/id_dsa -y > /root/.ssh/id_dsa.pub')
            .that_subscribes_to('File[/root/.ssh/id_dsa]')
        }
        if ['redhat-7-x86_64', 'centos-7-x86_64'].include?(os)
          it {
            is_expected.to contain_exec('add /root/.ssh/id_dsa.pub comment')
              .with_command('ssh-keygen -f /root/.ssh/id_dsa -c -C root@web0c0')
              .that_subscribes_to('Exec[generate /root/.ssh/id_dsa.pub]')
          }
        end
      end

      context 'with custom home directory' do
        let(:title) { 'jenkins@web0c0' }
        let(:params) do
          super().merge(
            'user_name'       => 'jenkins',
            'sshkey_dir'      => '/var/lib/jenkins/.ssh',
            'generate_public' => true,
          )
        end

        it { is_expected.to compile }
        it {
          is_expected.to contain_file('/var/lib/jenkins/.ssh/id_rsa')
        }
        it {
          is_expected.to contain_exec('create /var/lib/jenkins/.ssh/id_rsa path')
            .with_command('mkdir -p /var/lib/jenkins/.ssh')
            .with_user('jenkins')
        }
        it {
          is_expected.to contain_exec('generate /var/lib/jenkins/.ssh/id_rsa.pub')
            .with_command('ssh-keygen -f /var/lib/jenkins/.ssh/id_rsa -y > /var/lib/jenkins/.ssh/id_rsa.pub')
            .that_subscribes_to('File[/var/lib/jenkins/.ssh/id_rsa]')
        }
        if ['redhat-7-x86_64', 'centos-7-x86_64'].include?(os)
          it {
            is_expected.to contain_exec('add /var/lib/jenkins/.ssh/id_rsa.pub comment')
              .with_command('ssh-keygen -f /var/lib/jenkins/.ssh/id_rsa -c -C jenkins@web0c0')
              .that_subscribes_to('Exec[generate /var/lib/jenkins/.ssh/id_rsa.pub]')
          }
        end
      end

      context 'with custom home directory and key prefix' do
        let(:title) { 'jenkins@web0c0' }
        let(:params) do
          super().merge(
            'user_name'       => 'jenkins',
            'sshkey_dir'      => '/var/lib/jenkins/.ssh',
            'key_prefix'      => 'gitlab',
            'generate_public' => true,
          )
        end

        it { is_expected.to compile }
        it {
          is_expected.to contain_file('/var/lib/jenkins/.ssh/gitlab.id_rsa')
        }
        it {
          is_expected.to contain_exec('generate /var/lib/jenkins/.ssh/gitlab.id_rsa.pub')
            .with_command('ssh-keygen -f /var/lib/jenkins/.ssh/gitlab.id_rsa -y > /var/lib/jenkins/.ssh/gitlab.id_rsa.pub')
            .that_subscribes_to('File[/var/lib/jenkins/.ssh/gitlab.id_rsa]')
        }
        if ['redhat-7-x86_64', 'centos-7-x86_64'].include?(os)
          it {
            is_expected.to contain_exec('add /var/lib/jenkins/.ssh/gitlab.id_rsa.pub comment')
              .with_command('ssh-keygen -f /var/lib/jenkins/.ssh/gitlab.id_rsa -c -C jenkins@web0c0')
              .that_subscribes_to('Exec[generate /var/lib/jenkins/.ssh/gitlab.id_rsa.pub]')
          }
        end
      end

      context 'with user jenkins' do
        let(:title) { 'jenkins@web0c0' }
        let(:params) do
          super().merge(
            'user_name'       => 'jenkins',
            'generate_public' => true,
          )
        end

        it {
          is_expected.to contain_exec('create /home/jenkins/.ssh/id_rsa path')
            .with_command('mkdir -p /home/jenkins/.ssh')
            .with_user('jenkins')
        }

        it {
          is_expected.to contain_file('/home/jenkins/.ssh/id_rsa')
            .with_content(rsa_key_data)
            .with_owner('jenkins')
            .with_group('jenkins')
            .that_requires('Exec[create /home/jenkins/.ssh/id_rsa path]')
        }

        it {
          is_expected.to contain_exec('generate /home/jenkins/.ssh/id_rsa.pub')
            .with_command('ssh-keygen -f /home/jenkins/.ssh/id_rsa -y > /home/jenkins/.ssh/id_rsa.pub')
            .with_refreshonly(true)
            .with_user('root')
            .that_subscribes_to('File[/home/jenkins/.ssh/id_rsa]')
        }

        it {
          is_expected.to contain_file('/home/jenkins/.ssh/id_rsa.pub')
            .with_owner('jenkins')
            .with_group('jenkins')
            .with_mode('0640')
            .that_requires('Exec[generate /home/jenkins/.ssh/id_rsa.pub]')
        }

        if ['redhat-7-x86_64', 'centos-7-x86_64'].include?(os)
          it {
            is_expected.to contain_exec('add /home/jenkins/.ssh/id_rsa.pub comment')
              .with_command('ssh-keygen -f /home/jenkins/.ssh/id_rsa -c -C jenkins@web0c0')
              .with_refreshonly(true)
              .with_user('root')
              .that_subscribes_to('Exec[generate /home/jenkins/.ssh/id_rsa.pub]')
          }

          context 'with provided ssh key name jenkins@gitlab' do
            let(:params) do
              super().merge(
                'sshkey_name' => 'jenkins@gitlab',
              )
            end

            it {
              is_expected.to contain_exec('add /home/jenkins/.ssh/id_rsa.pub comment')
                .with_command('ssh-keygen -f /home/jenkins/.ssh/id_rsa -c -C jenkins@gitlab')
            }
          end
        end

        context 'with provided ownership group users' do
          let(:params) do
            super().merge(
              'user_group' => 'users',
            )
          end

          it {
            is_expected.to contain_file('/home/jenkins/.ssh/id_rsa')
              .with_group('users')
          }
        end
      end

      context 'when input data provided from Hiera' do
        let(:pre_condition) do
          <<-PRECOND
          class profile::build::base (
            $gitlab_deploy_key,
            $gitlab_deploy_key_type,
            $gitlab_deploy_key_prefix,
          )
          {
            openssh::priv_key { 'gitlab':
              user_name   => 'root',
              key_data    => $gitlab_deploy_key,
              sshkey_type => $gitlab_deploy_key_type,
              key_prefix  => $gitlab_deploy_key_prefix,
            }
          }
          include profile::build::base
          PRECOND
        end
        let(:facts) do
          os_facts.merge(
            'stype' => 'stype6',
            'hostname' => 'bsys',
          )
        end

        it { is_expected.to compile }

        it {
          is_expected.to contain_file('/root/.ssh/gitlab.id_ecdsa')
            .with_content(ec_key_data)
            .that_requires('Exec[create /root/.ssh/gitlab.id_ecdsa path]')
        }
      end
    end
  end
end
