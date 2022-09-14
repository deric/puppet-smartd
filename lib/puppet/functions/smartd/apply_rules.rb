#
Puppet::Functions.create_function(:'smartd::apply_rules') do
  # @param disks
  # @param rules
  #
  # @return [Array]
  #   Applied rules to disks config
  #
  dispatch :default_impl do
    required_param 'Hash', :disks
    required_param 'Hash', :rules
  end

  def default_impl(disks, rules)
    devices = []
    disks.each do |name, params|
      disk = "/dev/#{name}"
      if params.include? 'vendor'
        disk << " -d #{params['vendor'].downcase}"
      end

      rules.each do |rule, cond|
        next unless params.include? rule
        next unless cond.include? 'match'
        if %r{#{cond['match']}}.match?(params[rule])
          disk << " #{cond['options']}" if cond.key? 'options'
        end
      end

      devices << disk
    end
    devices
  end
end
