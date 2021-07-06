# frozen_string_literal: true

require 'spec_helper'

describe 'openssh::profile::server' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      context 'when setup host keys' do
        let(:params) do
          {
            custom_ssh_keys: [
              {
                type: 'ssh-rsa',
                # rubocop:disable Metrics/LineLength
                key: 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDRzUkiTj2vWKNrdQtXV8KIVQ74+mBkS5E+fKIdRy6F/8N79Jqli0sx64O916YOGOwD+G7kRjjtXBVcL9xZ/Ur+OCpgAXgEGF8mPnP+mIBofE+OCxXnSbiLFuEiZybyh7MEiHpFaAn7pTLrbuU6gLO2nIs3bnM6FDYajoM0vhZPkKwuRUfE5gNG5sGDDYD2fhwafFsGBjnMjH0atakrKno9lQXkQMDg/hvELgHbbSglq3/h9R2gtKVk6R+tCBn+7b9iKFS2lw3vvb90uVwSOpLIOxefJ1acBspKzRFJrrDP2Obp3jLEzL+fSWGWXudGKsS0NkcV15p2wtRaTEAt9ryf',
                # rubocop:enable Metrics/LineLength
                name: 'Generated-by-Nova',
              },
            ],
          }
        end

        it {
          is_expected.to contain_file('/root/.ssh/authorized_keys')
            .with_content(%r{^ssh-rsa AAAAB3NzaC1yc2EAAAADA.*fSWGWXudGKsS0NkcV15p2wtRaTEAt9ryf Generated-by-Nova$})
        }
      end
    end
  end
end
