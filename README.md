# powershellmodule

[![Build Status](https://travis-ci.org/EncoreTechnologies/puppet-powershellmodule.svg?branch=master)](https://travis-ci.org/EncoreTechnologies/puppet-powershellmodule)
[![Puppet Forge Version](https://img.shields.io/puppetforge/v/encore/powershellmodule.svg)](https://forge.puppet.com/encore/powershellmodule)
[![Puppet Forge Downloads](https://img.shields.io/puppetforge/dt/encore/powershellmodule.svg)](https://forge.puppet.com/encore/powershellmodule)
[![Puppet Forge Score](https://img.shields.io/puppetforge/f/encore/powershellmodule.svg)](https://forge.puppet.com/encore/powershellmodule)
[![Puppet PDK Version](https://img.shields.io/puppetforge/pdk-version/encore/powershellmodule.svg)](https://forge.puppet.com/encore/powershellmodule)
[![puppetmodule.info docs](http://www.puppetmodule.info/images/badge.png)](http://www.puppetmodule.info/m/encore-powershellmodule)

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
    * [Full working example](#full-working-example)
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

### PowerShell Core

PowerShellGet is included in PowerShell Core so no additional setup is necessary.

## Usage

### Install PowerShellGet PackageProviders


You can install PackageProviders for PowerShelLGet using the `pspackageprovider` type.

```puppet
pspackageprovider {'ExampleProvider':
  ensure   => 'present',
  provider => 'windowspowershell',
}
```

In order to use this module to to get packages from a PSRepository like the `PSGallery`, you will have to ensure the `Nuget` provider is installed:

```puppet
pspackageprovider {'Nuget':
  ensure   => 'present',
  provider => 'windowspowershell',
}
```

You can optionally specify the version of a PackageProvider using the `version` parameter.

```puppet
pspackageprovider {'Nuget':
  ensure   => 'present',
  version  => '2.8.5.208',
  provider => 'windowspowershell',
}
```

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

### Full Working example

This complete example shows how to bootstrap the system with the Nuget package provider, ensure the PowerShell Gallery repository is configured and trusted, and install two modules (one using the WindowsPowerShell provider and one using the PowerShellCore provider).

```puppet
pspackageprovider {'Nuget':
  ensure => 'present'
}

psrepository { 'PSGallery':
  ensure              => present,
  source_location     => 'https://www.powershellgallery.com/api/v2/',
  installation_policy => 'trusted',
}

package { 'xPSDesiredStateConfiguration':
  ensure   => latest,
  provider => 'windowspowershell',
  source   => 'PSGallery',
  install_options => [ '-AllowClobber' ]
}

package { 'Pester':
  ensure   => latest,
  provider => 'powershellcore',
  source   => 'PSGallery',
}
```

## Limitations

Note that PowerShell modules can be installed side by side so installing a newer
version of a module will not remove any previous versions.

- As detailed in https://github.com/OneGet/oneget/issues/308, installing PackageProviders from a offline location instead of online is currently not working. A workaround is to use the Puppet file resource to ensure the prescence of the file before attempting to use the NuGet PackageProvider.

The following is an incompelete example that copies the NuGet provider dll to the directory that PowerShellGet expects. You would have to modify this declaration to complete the permissions for the target and the location of the source file.

```
file{"C:\Program Files\PackageManagement\ProviderAssemblies\nuget\2.8.5.208\Microsoft.PackageManagement.NuGetProvider.dll":
  ensure => 'file',
  source => "$source\nuget\2.8.5.208\Microsoft.PackageManagement.NuGetProvider.dll"
}

```

## Reference

### Types

* [package](#package)
* [pspackageprovider](#pspackageprovider)
* [psrepository](#psrepository)

### package

`puppet-powershellmodule` implements a [package type](http://docs.puppet.com/references/latest/type.html#package) with a resource provider, which is built into Puppet.

The implementation supports the [install_options](https://puppet.com/docs/puppet/6.2/type.html#package-attribute-install_options) attribute which can be used to pass additional options to the PowerShell Install-Modules command, e.g.:

```
package { 'xPSDesiredStateConfiguration':
  ensure   => latest,
  provider => 'windowspowershell',
  source   => 'PSGallery',
  install_options => [ '-AllowClobber',
                       { '-proxy' => 'http://proxy.local.domain' }  ]
}

```

### pspackageprovider

#### Properties/Parameters

##### `ensure`

Specifies what state the PowerShellGet provider should be in. Valid options: `present` and `absent`. Default: `present`.

##### `name`

Specifies the name of the PowerShellGet provider to install.

##### `version`

Specifies the version of the PowerShellGet provider to install

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

https://github.com/EncoreTechnologies/puppet-powershellmodule
