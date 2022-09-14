# frozen_string_literal: true

require 'spec_helper'

describe 'smartd' do
  describe 'Update smartd config' do
    # OS is irrelevant, template shouldn't be OS dependent
    let(:facts) do
      {
        os: {
          family: 'Debian',
        }
      }
    end

    context 'with devicescan' do
      let(:params) do
        {
          devicescan: true,
          options: ['-d ata', '-m root@example.com']
        }
      end

      it {
        is_expected.to contain_file('/etc/smartd.conf')\
          .with_content(%r{^DEVICESCAN -d ata -m root@example.com})
      }
    end

    context 'with defaults' do
      let(:params) do
        {
          defaults: ['-m root@example.com']
        }
      end

      it {
        is_expected.to contain_file('/etc/smartd.conf')\
          .with_content(%r{^DEFAULT -m root@example.com})
      }
    end
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
      it { is_expected.to contain_class('smartd') }
      it { is_expected.to contain_package('smartmontools') }
      it { is_expected.to contain_service('smartd') }

      case os_facts[:osfamily]
      when 'Debian', 'SuSE'
        it { is_expected.to contain_file('/etc/smartd.conf').with_ensure('file') }
      when 'RedHat'
        it { is_expected.to contain_file('/etc/smartmontools/smartd.conf').with_ensure('file') }
      end
    end
  end
end