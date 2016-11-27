Puppet::Type.type(:powershellmodule).provide(:windows) do
  confine :operatingsystem => :windows
  confine :feature => :powershellget

  commands :powershell =>
              if File.exists?("#{ENV['SYSTEMROOT']}\\sysnative\\WindowsPowershell\\v1.0\\powershell.exe")
                "#{ENV['SYSTEMROOT']}\\sysnative\\WindowsPowershell\\v1.0\\powershell.exe"
              elsif File.exists?("#{ENV['SYSTEMROOT']}\\system32\\WindowsPowershell\\v1.0\\powershell.exe")
                "#{ENV['SYSTEMROOT']}\\system32\\WindowsPowershell\\v1.0\\powershell.exe"
              else
                'powershell.exe'
              end

  def exists?
    command = "$mod = Get-InstalledModule #{@resource[:name]}; $mod.Name"
    result = powershell(['-noprofile', '-executionpolicy', 'bypass', '-command', command])
    debug(result)
    result.downcase.strip == resource[:name]
  end

  def destroy
    command = "Uninstall-Module #{@resource[:name]} -AllVersions"
    result = powershell(['-noprofile', '-executionpolicy', 'bypass', '-command', command])
    debug(result)
  end

  def create
    case resource[:version]
      when nil
        command = "Install-Module #{@resource[:name]} -Force"
      else
        command = "Install-Module #{@resource[:name]} -RequiredVersion #{@resource[:version]} -Force"
    end
    case resource[:repository]
      when nil
        #do nothing
      else
        command = command + " -Repository #{@resource[:repository]}"
    end
    result = powershell(['-noprofile', '-executionpolicy', 'bypass', '-command', command])
    debug(result)
  end

  def version
    command = "$mod = Get-InstalledModule #{@resource[:name]} -RequiredVersion #{@resource[:version]} -ErrorAction SilentlyContinue; try{$mod.Version.ToString()}catch{''}"
    result = powershell(['-noprofile', '-executionpolicy', 'bypass', '-command', command])
    debug(result)
    result.downcase.strip
  end

  def version=(value)
    command = "Install-Module #{@resource[:name]} -RequiredVersion #{value} -Force"
    result = powershell(['-noprofile', '-executionpolicy', 'bypass', '-command', command])
    debug(result)
  end
end