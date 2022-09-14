# frozen_string_literal: true

require 'spec_helper'

describe 'smartd::apply_rules' do
  it { is_expected.to run.with_params({}, {}).and_return([]) }
  it { is_expected.to run.with_params(nil).and_raise_error(StandardError) }

  context 'with ATA disks' do
    disks = {
      'sda' => {
        'model' => 'Micron_1100_MTFD',
        'vendor' => 'ATA',
      }
    }
    it { is_expected.to run.with_params(disks, {}).and_return(['/dev/sda -d ata']) }

    rules = {
      'model' => {
        'match' => 'Micron',
        'options' => '-I 173',
      }
    }

    it {
      is_expected.to run.with_params(disks, rules)\
                        .and_return(['/dev/sda -d ata -I 173'])
    }
  end
end
