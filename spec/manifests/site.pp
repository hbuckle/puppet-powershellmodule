exec { 'nuget':
    command  => 'Install-PackageProvider -Name NuGet -ForceBootstrap',
    provider => powershell
}

package { 'Posh-SSH':
    ensure   => latest,
    provider => psmodule,
}