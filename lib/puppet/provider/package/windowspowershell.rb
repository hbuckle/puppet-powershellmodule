Puppet::Type.type(:package).provide(:windowspowershell, parent: :powershellcore) do
  initvars
  confine operatingsystem: :windows
  confine feature: :powershellgetwindows
  has_feature :installable, :uninstallable, :upgradeable, :versionable, :install_options
  commands powershell: 'powershell'

  def self.invoke_ps_command(command)
    result = powershell(['-NoProfile', '-ExecutionPolicy', 'Bypass', '-NonInteractive', '-NoLogo', '-Command',
                         "$ProgressPreference = 'SilentlyContinue'; $ErrorActionPreference = 'Stop'; [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12; #{command}"])
    result.lines
  end
end
