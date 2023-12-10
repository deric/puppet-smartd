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

    describe command("systemctl status #{service}") do
      its(:stdout) { is_expected.to match(%r{smart}) }
    end
  end
end
