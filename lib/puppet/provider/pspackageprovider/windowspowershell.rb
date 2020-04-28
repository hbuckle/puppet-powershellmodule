Puppet::Type.type(:pspackageprovider).provide(:windowspowershell, parent: :powershellcore) do
  confine operatingsystem: :windows
  commands powershell: 'powershell'

  def self.invoke_ps_command(command)
    result = powershell(['-NoProfile', '-ExecutionPolicy', 'Bypass', '-NonInteractive', '-NoLogo', '-Command',
                         # The following section of the -Command forces powershell to use tls1.2 (which it does not by default currently unless set system wide): [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
                         # Without tls1.2 you cannot install modules from PSGallery
                         "$ProgressPreference = 'SilentlyContinue'; $ErrorActionPreference = 'Stop'; [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12; #{command}"])
    result.lines
  end
end
