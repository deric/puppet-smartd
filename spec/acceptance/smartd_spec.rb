# frozen_string_literal: true

require 'spec_helper_acceptance'
require 'pry'

describe 'smartd' do
  context 'basic setup' do
    it 'install smartd' do
      pp = <<~EOS
        class { 'smartd':
          manage_service => false,  # in cloud CI smart might not be available
        }
      EOS

      apply_manifest(pp, catch_failures: false)
      apply_manifest(pp, catch_changes: true)
    end

    if os[:family] == 'debian'
      config = '/etc/smartd.conf'
    elsif os[:family] == 'redhat'
      config = '/etc/smartmontools/smartd.conf'
    else
      puts os[:family]
    end

    describe file(config) do
      it { is_expected.to be_file }
      it { is_expected.to be_readable.by('owner') }
      it { is_expected.to be_readable.by('group') }
    end
  end
end
