require 'spec_helper'

describe 'openssh::auth_key' do
  let(:title) { 'namevar' }
  let(:params) do
    {
      sshkey_user: 'user',
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end
  end
end
