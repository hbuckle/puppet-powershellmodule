class Puppet::Provider::Ps < Puppet::Provider
  confine operatingsystem: :windows
  confine feature: :powershellget
  initvars

  commands :powershell =>
              if File.exist?("#{ENV['SYSTEMROOT']}\\sysnative\\WindowsPowershell\\v1.0\\powershell.exe")
                "#{ENV['SYSTEMROOT']}\\sysnative\\WindowsPowershell\\v1.0\\powershell.exe"
              elsif File.exist?("#{ENV['SYSTEMROOT']}\\system32\\WindowsPowershell\\v1.0\\powershell.exe")
                "#{ENV['SYSTEMROOT']}\\system32\\WindowsPowershell\\v1.0\\powershell.exe"
              else
                'powershell.exe'
              end

  def invoke_ps_command(command)
    result = powershell(['-noprofile', '-executionpolicy', 'bypass', '-command', command])
    Puppet.debug result
  end

end
