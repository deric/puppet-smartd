# frozen_string_literal: true

require 'spec_helper_acceptance'
require 'pry'

describe 'smartd' do
  context 'basic setup' do
    it 'install smartd' do
      pp = <<~EOS
        include smartd
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe file('/etc/smartd.conf') do
      it { is_expected.to be_file }
      it { is_expected.to be_readable.by('owner') }
      it { is_expected.to be_readable.by('group') }
    end

    describe service('smartmontools') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end
  end
end
