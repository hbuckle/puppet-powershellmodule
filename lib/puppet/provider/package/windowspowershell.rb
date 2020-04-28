Puppet::Type.type(:package).provide(:windowspowershell, parent: :powershellcore) do
  initvars
  confine operatingsystem: :windows
  confine feature: :powershellgetwindows
  has_feature :installable, :uninstallable, :upgradeable, :versionable, :install_options
  commands powershell: 'powershell'

  def self.invoke_ps_command(command)
    # The SecurityProtocol section of the -Command forces PowerShell to use TLSv1.2,
    # which is not enabled by default unless explicitly configured system-wide in the registry.
    # The PowerShell Gallery website enforces the use of TLSv1.2 for all incoming connections,
    # so without forcing TLSv1.2 here the command will fail.
    sec_proto_cmd = '[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12'
    result = powershell(['-NoProfile', '-ExecutionPolicy', 'Bypass', '-NonInteractive', '-NoLogo', '-Command',
                         "$ProgressPreference = 'SilentlyContinue'; $ErrorActionPreference = 'Stop'; #{sec_proto_cmd}; #{command}"])
    result.lines
  end
end
