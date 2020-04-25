Puppet::Type.type(:pspackageprovider).provide(:windowspowershell, parent: :powershellcore) do
  confine operatingsystem: :windows
  commands powershell: 'powershell'

  def self.invoke_ps_command(command)
    result = powershell(['-NoProfile', '-ExecutionPolicy', 'Bypass', '-NonInteractive', '-NoLogo', '-Command',
                         "$ProgressPreference = 'SilentlyContinue'; $ErrorActionPreference = 'Stop'; [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12; #{command}"])
    result.lines
  end
end
