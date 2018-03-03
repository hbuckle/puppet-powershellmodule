# powershellmodule

#### Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with powershellmodule](#setup)
    * [Setup requirements](#setup-requirements)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

This module allows PowerShell repositories to be registered as package sources
and PowerShell modules to be installed using the Puppet Package type.

The module supports Windows PowerShell (PowerShell 5) and PowerShell Core (PowerShell 6)

## Setup

### Setup Requirements

For Windows PowerShell the PowerShellGet PowerShell module must be installed as well as
the NuGet package provider. PowerShellGet is included with WMF5 or can be installed for earlier
versions here http://go.microsoft.com/fwlink/?LinkID=746217&clcid=0x409

NuGet can be installed by running

`Install-PackageProvider Nuget –Force`

## Usage

### Windows PowerShell

~~~ puppet
psrepository { 'my-internal-repo':
  ensure              => present,
  source_location     => 'http://myrepo.corp.com/api/nuget/powershell',
  installation_policy => 'trusted',
  provider            => 'windowspowershell',
}
~~~

~~~ puppet
package { 'Pester':
  ensure   => '4.0.3',
  source   => 'PSGallery',
  provider => 'windowspowershell',
}
~~~

### PowerShell Core

~~~ puppet
psrepository { 'my-internal-repo':
  ensure              => present,
  source_location     => 'http://myrepo.corp.com/api/nuget/powershell',
  installation_policy => 'trusted',
  provider            => 'powershellcore',
}
~~~

~~~ puppet
package { 'Pester':
  ensure   => '4.0.3',
  source   => 'PSGallery',
  provider => 'powershellcore',
}
~~~

## Limitations

Note that PowerShell modules can be installed side by side so installing a newer
version of a module will not remove any previous versions.

## Development

https://github.com/hbuckle/puppet-powershellmodule