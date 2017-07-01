# powershellmodule

#### Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with powershellmodule](#setup)
    * [Setup requirements](#setup-requirements)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

This module adds a new type and provider for registering PowerShell repositories
and a new package provider for installing PowerShell modules.

## Setup

### Setup Requirements

The PowerShellGet PowerShell module must be installed as well as the NuGet package
provider. PowerShellGet is included with WMF5 or can be installed for earlier
versions here http://go.microsoft.com/fwlink/?LinkID=746217&clcid=0x409
NuGet can be installed by running
Install-PackageProvider Nuget –Force

### Beginning with powershellmodule

## Usage

~~~ puppet
psrepository { 'my-internal-repo':
  source_location     => 'http://myrepo.corp.com/api/nuget/powershell',
  installation_policy => trusted,
}
~~~

~~~ puppet
package { 'pester':
  ensure   => '4.0.3',
  source   => 'PSGallery',
  provider => 'psmodule',
}
~~~

## Limitations

Note that PowerShell modules can be installed side by side so installing a newer
version of a module will not remove any previous versions.

## Development

https://github.com/hbuckle/puppet-powershellmodule