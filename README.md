# powershellmodule

#### Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with powershellmodule](#setup)
    * [Windows PowerShell](#windows-powershell)
    * [PowerShell Core](#powershell-core)
1. [Usage - Configuration options and additional functionality](#usage)
    * [Windows PowerShell](#windows-powershell)
    * [PowerShell Core](#powershell-core)
    * [Side by side installation](#side-by-side-installation)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

This module allows PowerShell repositories to be registered as package sources
and PowerShell modules to be installed using the Puppet Package type.

The module supports Windows PowerShell (PowerShell 5) and PowerShell Core (PowerShell 6)

## Setup

### Windows PowerShell

For Windows PowerShell the PowerShellGet PowerShell module must be installed as well as
the NuGet package provider. PowerShellGet is included with WMF5 or can be installed for earlier
versions here http://go.microsoft.com/fwlink/?LinkID=746217&clcid=0x409

NuGet can be installed by running

`Install-PackageProvider Nuget –Force`

### PowerShell Core

PowerShellGet is included in PowerShell Core so no additional setup is necessary.

## Usage

### Windows PowerShell

Windows users should remember that package names in Puppet are case sensitive.

```puppet
psrepository { 'my-internal-repo':
  ensure              => present,
  source_location     => 'http://myrepo.corp.com/api/nuget/powershell',
  installation_policy => 'trusted',
  provider            => 'windowspowershell',
}
```

```puppet
package { 'Pester':
  ensure   => '4.0.3',
  source   => 'PSGallery',
  provider => 'windowspowershell',
}
```

### PowerShell Core

```puppet
psrepository { 'my-internal-repo':
  ensure              => present,
  source_location     => 'http://myrepo.corp.com/api/nuget/powershell',
  installation_policy => 'trusted',
  provider            => 'powershellcore',
}
```

```puppet
package { 'Pester':
  ensure   => '4.0.3',
  source   => 'PSGallery',
  provider => 'powershellcore',
}
```

### Side by side installation

On Windows, PowerShell Core is installed along side Windows PowerShell and maintains its
modules separately. To install the same module for both versions then use a unique resource
title and specify the `name` property.

```puppet
package { 'PSExcel-wps':
  ensure   => latest,
  name     => 'PSExcel',
  provider => 'windowspowershell',
  source   => 'PSGallery',
}

package { 'PSExcel-psc':
  ensure   => latest,
  name     => 'PSExcel',
  provider => 'powershellcore',
  source   => 'PSGallery',
}
```

## Limitations

Note that PowerShell modules can be installed side by side so installing a newer
version of a module will not remove any previous versions.

## Development

https://github.com/hbuckle/puppet-powershellmodule