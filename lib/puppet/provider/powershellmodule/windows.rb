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
    unless result.downcase.strip == ''
      fail(result)
    end
  end

  def create
    case resource[:version]
      when nil || 'latest'
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
    unless result.downcase.strip == ''
      fail(result)
    end
  end

  def version
    case resource[:version]
      when 'latest'
        latestcommand = "$mod = Find-Module #{@resource[:name]}; $mod.Version.ToString()"
        latestresult = powershell(['-noprofile', '-executionpolicy', 'bypass', '-command', latestcommand])
        actualcommand = "$mod = Get-InstalledModule #{@resource[:name]}; $mod.Version.ToString()"
        actualresult = powershell(['-noprofile', '-executionpolicy', 'bypass', '-command', actualcommand])
        debug(latestresult)
        if latestresult.downcase.strip == actualresult.downcase.strip
          return 'latest'
        else
          notice("Latest version available is #{latestresult.downcase.strip}")
          return actualresult.downcase.strip
        end
      else
        specificcommand = "$mod = Get-InstalledModule #{@resource[:name]} -RequiredVersion #{@resource[:version]} -ErrorAction SilentlyContinue; try{$mod.Version.ToString()}catch{''}"
        specificresult = powershell(['-noprofile', '-executionpolicy', 'bypass', '-command', specificcommand])
        debug(specificresult)
        specificresult.downcase.strip
    end
  end

  def version=(value)
    case value
      when 'latest'
        command = "Update-Module #{@resource[:name]} -Force"
      else
        command = "Install-Module #{@resource[:name]} -RequiredVersion #{value} -Force"
        case resource[:repository]
          when nil
            #do nothing
          else
            command = command + " -Repository #{@resource[:repository]}"
        end
    end
    result = powershell(['-noprofile', '-executionpolicy', 'bypass', '-command', command])
    debug(result)
    unless result.downcase.strip == ''
      fail(result)
    end
  end
end