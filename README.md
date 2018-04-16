# powershellmodule

#### Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with powershellmodule](#setup)
    * [Windows PowerShell](#windows-powershell)
    * [PowerShell Core](#powershell-core)
1. [Usage](#usage)
    * [Register an internal PowerShell repository](#register-an-internal-powershell-repository)
    * [Use the PowerShell Gallery](#use-the-powershell-gallery)
    * [Side by side installation](#side-by-side-installation)
    * [The provider](#the-provider)
1. [Reference](#reference)
    * [Types](#types)
    * [Providers](#providers)
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

### Register an internal PowerShell repository

```puppet
psrepository { 'my-internal-repo':
  ensure              => present,
  source_location     => 'http://myrepo.corp.com/api/nuget/powershell',
  installation_policy => 'trusted',
  provider            => 'windowspowershell',
}
```

Manifests can then refer to that repository using the `package` resource.

```puppet
package { 'nameOfInternallyDevelopedModule':
  ensure   => '1.0.5',
  source   => 'my-internal-repo',
  provider => 'windowspowershell',
}
```

*Windows users should remember that package names in Puppet are case sensitive.

### Use the PowerShell Gallery

You can install modules from the PowerShell Gallery by default once the [setup instructions](#Setup) have been followed. You do not need to specify the `PSGallery` with the `psrepository` type.

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

### The provider

The provider to use will either be `windowspowershell` or `powershellcore`. Nodes using `powershell.exe` will use `windowspowershell`, and nodes that have PowerShell core (`pwsh.exe`) will use the `powershellcore` provider with both the `psrepository` and `package` types.

## Limitations

Note that PowerShell modules can be installed side by side so installing a newer
version of a module will not remove any previous versions.

## Reference

### Types

### psrepository

Allows you to specify and configure a repository. The type expects a valid OneGet package provider source over an HTTP or HTTPS url.

#### Properties/Parameters

#### `name`

The name of the gallery to register on the computer. Must be unique. Cannot use `PSGallery` as the value for this property.

#### `source_location`

The url to the repository that you would like to register. Must be a valid HTTP or HTTPS url. This url will be used for the underlying `SourceLocation` property and will be used as the base url for `PublishLocation`, `ScriptSourceLocation`, `ScriptPublishLocation`. Cannot use the same url as the default gallery, PSGallery.

#### `installation_policy`

Manages the installation policy used for the PSRepository. Valid values are `trusted` or `untrusted`

### Providers
#### `windowspowershell`

The provider for systems that have `powershell.exe` (PowerShell versions less than 6).

#### `powershellcore`

The provider for systems that use PowerShell core via `pwsh.exe`.

## Development

https://github.com/hbuckle/puppet-powershellmodule