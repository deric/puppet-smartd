# frozen_string_literal: true

require 'spec_helper'

describe 'smartd::apply_rules' do
  it { is_expected.to run.with_params({}, []).and_return([]) }
  it { is_expected.to run.with_params(nil).and_raise_error(StandardError) }

  context 'with ATA disks' do
    disks = {
      'sda' => {
        'model' => 'Micron_1100_MTFD',
        'vendor' => 'ATA',
      }
    }
    it { is_expected.to run.with_params(disks, []).and_return(['/dev/sda -d ata']) }

    rules = [
      {
        'attr' => 'model',
        'match' => 'Micron',
        'options' => '-I 173',
      },
    ]

    it {
      is_expected.to run.with_params(disks, rules)\
                        .and_return(['/dev/sda -d ata -I 173'])
    }
  end

  context 'with NVMe disks' do
    disks = {
      'sda' => {
        'model' => 'Micron_1100_MTFD',
        'vendor' => 'ATA',
      },
      'nvme0n1' => {
        'model' => 'SAMSUNG MZQL2960HCJR-00A07',
      }
    }
    rules = [
      {
        'attr' => '$name',
        'match' => '^nvme',
        'options' => '-H',
      },
    ]

    it { is_expected.to run.with_params(disks, []).and_return(['/dev/sda -d ata', '/dev/nvme0n1']) }

    it {
      is_expected.to run.with_params(disks, rules)\
                        .and_return(['/dev/sda -d ata', '/dev/nvme0n1 -H'])
    }
  end

  context 'with action=ignore' do
    disks = {
      'sda' => {
        'model' => 'PERC H730P Mini',
        'vendor' => 'DELL',
      }
    }
    rules = [
      {
        'attr' => 'vendor',
        'match' => 'DELL',
        'action' => 'ignore',
      },
    ]

    it { is_expected.to run.with_params(disks, rules).and_return([]) }
  end
end
