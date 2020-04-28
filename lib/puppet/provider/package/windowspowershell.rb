Puppet::Type.type(:package).provide(:windowspowershell, parent: :powershellcore) do
  initvars
  confine operatingsystem: :windows
  confine feature: :powershellgetwindows
  has_feature :installable, :uninstallable, :upgradeable, :versionable, :install_options
  commands powershell: 'powershell'

  def self.invoke_ps_command(command)
    result = powershell(['-NoProfile', '-ExecutionPolicy', 'Bypass', '-NonInteractive', '-NoLogo', '-Command',
                         # The following section of the -Command forces powershell to use tls1.2 (which it does not by default currently unless set system wide): [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
                         # Without tls1.2 you cannot install modules from PSGallery
                         "$ProgressPreference = 'SilentlyContinue'; $ErrorActionPreference = 'Stop'; [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12; #{command}"])
    result.lines
  end
end
