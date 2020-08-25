# frozen_string_literal: true

require 'spec_helper'

describe 'openssh::profile::server' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts.merge(
          'stype' => 'stype7',
        )
      end

      it { is_expected.to compile }
    end
  end
end
