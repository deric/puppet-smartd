# frozen_string_literal: true

require 'spec_helper'

describe 'smartd' do
  # OS dependent tests
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
      it { is_expected.to contain_class('smartd') }
      it { is_expected.to contain_package('smartmontools') }

      case os_facts[:os]['family']
      when 'RedHat'
        it { is_expected.to contain_file('/etc/smartmontools/smartd.conf').with_ensure('file') }
      else
        it { is_expected.to contain_file('/etc/smartd.conf').with_ensure('file') }
      end

      case os_facts[:os]['family']
      when 'Debian', 'SuSE'
        case os_facts[:os]['release']['major']
        when '9', '10'
          # rubocop:disable RSpec/RepeatedExample
          it { is_expected.to contain_service('smartd') }
        else
          it { is_expected.to contain_service('smartmontools') }
        end
      else
        it { is_expected.to contain_service('smartd') }
      end
    end
  end

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

    context 'with devicescan and string options' do
      let(:params) do
        {
          devicescan: true,
          options: '-d ata -H'
        }
      end

      it {
        is_expected.to contain_file('/etc/smartd.conf')\
          .with_content(%r{^DEVICESCAN -d ata -H})
      }
    end

    context 'with devicescan without options' do
      let(:params) do
        {
          devicescan: true,
        }
      end

      it {
        is_expected.to contain_file('/etc/smartd.conf')\
          .with_content(%r{^DEVICESCAN})
      }
    end

    context 'without devicescan' do
      let(:params) do
        {
          devicescan: false,
        }
      end

      it {
        is_expected.not_to contain_file('/etc/smartd.conf')\
          .with_content(%r{^DEVICESCAN})
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

    context 'with ATA disk' do
      let(:params) do
        {
          disks: {
            sda: {
              model: 'SAMSUNG MZ7LN256',
              type: 'ssd',
              vendor: 'ATA'
            }
          }
        }
      end

      it {
        is_expected.to contain_file('/etc/smartd.conf')
          .with_content(%r{^/dev/sda -d ata})
      }
    end

    context 'with package_options' do
      let(:params) do
        {
          package_options: ['-t', 'buster-backports']
        }
      end

      it {
        is_expected.to contain_package('smartmontools')
          .with_ensure(%r{present|installed})
      }

      it {
        is_expected.to contain_package('smartmontools')
          .with_install_options(['-t', 'buster-backports'])
      }
    end

    context 'with hardware RAID' do
      let(:params) do
        {
          disks: {
            sda: {
              model: 'PERC H730P Mini',
              type: 'hdd',
              vendor: 'DELL'
            }
          },
          rules: [
            {
              attr: 'vendor',
              match: 'DELL',
              action: 'ignore',
            },
          ]
        }
      end

      it {
        is_expected.to contain_file('/etc/smartd.conf')
          .without_content(%r{^/dev/sda})
      }
    end

    context 'with multiple rules' do
      let(:params) do
        {
          disks: {
            sda: {
              model: 'Micron_1100_MTFDDAK256TBN',
              type: 'ssd',
              vendor: 'ATA'
            }
          },
          rules: [
            {
              attr: 'model',
              match: '^SAMSUNG MZ7',
              options: '-i 173',
            },
            {
              attr: 'model',
              match: '^Micron_1100',
              options: [
                '-C 197',
                '-U 198',
              ],
            },
          ]
        }
      end

      it {
        is_expected.to contain_file('/etc/smartd.conf')
          .with_content(%r{^/dev/sda -d ata -C 197 -U 198})
      }
    end
  end
end
