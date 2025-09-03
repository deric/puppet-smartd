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
    required_param 'Array', :rules
  end

  def default_impl(disks, rules)
    devices = []
    disks.each do |name, params|
      disk = "/dev/#{name}"
      apply = true
      rules.each do |cond|
        raise "Missing 'attr' in #{cond}" unless cond.key? 'attr'
        rule = cond['attr']
        # match device name
        if rule == '$name'
          apply &= match_rule(disk, cond, name)
        end
        # check if rule names matches disk atrributes
        next unless params.key? rule
        apply &= match_rule(disk, cond, params[rule])
      end

      devices << disk if apply
    end
    devices
  end

  # check conditions if needle is found
  def match_rule(disk, cond, needle)
    # regexp match
    if cond.key? 'match'
      if %r{#{cond['match']}}.match?(needle)
        if cond.key? 'action'
          case cond['action']
          when 'ignore'
            return false
          end
        elsif cond.key? 'options'
          opts = if cond['options'].is_a? Array
                   cond['options'].join(' ')
                 else
                   cond['options']
                 end
          disk << " #{opts}"
        end
      end
    end
    true
  end
end
