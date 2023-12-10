# frozen_string_literal: true

require 'spec_helper_acceptance'
require 'pry'

describe 'smartd' do
  context 'basic setup' do
    it 'install smartd' do
      pp = <<~EOS
        include smartd
      EOS

      apply_manifest(pp, catch_failures: false)
      apply_manifest(pp, catch_changes: true)
    end

    if os[:family] == 'debian'
      service = 'smartmontools'
      config = '/etc/smartd.conf'
    elsif os[:family] == 'redhat'
      service = 'smartd'
      config = '/etc/smartmontools/smartd.conf'
    else
      puts os[:family]
    end

    describe file(config) do
      it { is_expected.to be_file }
      it { is_expected.to be_readable.by('owner') }
      it { is_expected.to be_readable.by('group') }
    end

    it 'start the service' do
      run_shell("systemctl status #{service}", expect_failures: true) do |r|
        expect(r.stdout.include?('smartd')).to be false
      end
    end
  end
end
