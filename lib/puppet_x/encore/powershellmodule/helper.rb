require 'puppet_x'
require 'singleton'
begin
  require 'ruby-pwsh'
rescue LoadError
  raise 'Could not load the "ruby-pwsh" library; is the dependency module puppetlabs-pwshlib installed in this environment?'
end

module PuppetX::PowerShellModule
  # Helper class for Caching Instances
  class Helper
    include Singleton

    def initialize
      @powershell = Pwsh::Manager.instance(Pwsh::Manager.powershell_path,
                                           Pwsh::Manager.powershell_args)
      @pwsh = Pwsh::Manager.instance(Pwsh::Manager.pwsh_path,
                                     Pwsh::Manager.pwsh_args)
    end

    def setup_cmd
      "$ProgressPreference = 'SilentlyContinue'; $ErrorActionPreference = 'Stop'"
    end

    def sec_proto_cmd
      # The SecurityProtocol section of the -Command forces PowerShell to use TLSv1.2,
      # which is not enabled by default unless explicitly configured system-wide in the registry.
      # The PowerShell Gallery website enforces the use of TLSv1.2 for all incoming connections,
      # so without forcing TLSv1.2 here the command will fail.
      '[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12'
    end

    def full_cmd(command)
      "#{setup_cmd}; #{sec_proto_cmd}; #{command}"
    end

    def process_result(result, command, fail_on_failure: true, full_result: false)
      Puppet.debug("Result for command: #{command}\n stdout = #{result[:stdout]} \n stderr = #{result[:stderr]}")
      if fail_on_failure && result[:exitcode] != 0
        raise "Error when executing command: #{command}\n stdout = #{result[:stdout]} \n stderr = #{result[:stderr]}"
      end

      # should we return full result or stdout broken-up by lines
      if full_result
        result
      else
        result[:stdout].lines
      end
    end

    def pwsh(command, fail_on_failure: true, full_result: false)
      cmd = full_cmd(command)
      Puppet.debug("Running pwsh command: #{cmd}")
      result = @pwsh.execute(cmd)
      process_result(result, cmd, fail_on_failure: fail_on_failure, full_result: full_result)
    end

    def powershell(command, fail_on_failure: true, full_result: false)
      cmd = full_cmd(command)
      Puppet.debug("Running powershell command: #{cmd}")
      result = @powershell.execute(cmd)
      process_result(result, cmd, fail_on_failure: fail_on_failure, full_result: full_result)
    end
  end
end
