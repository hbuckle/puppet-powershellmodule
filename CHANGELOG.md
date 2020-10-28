## Development

* Fixed bug where CDNs requiring TLSv1.2 caused an idempotency issue in `psrepository` on 
  older Windos versions. (Bugfix) #12

## 2.1.0 (2020-04-28)

* `psrepository` - Fixed the inability to register psrepoositorys when none are registered on the node prior to puppet due to bug in `instances_command` expecting a returned hashtable. (Bugfix)

* `psrepository` - Many fixes around the default powershell gallery repo due to the `flush` command attempting to set the source_location of the repo.  (Bugfix)

* `psrepository` - Fixed the inability to change the installation policy of a pre-existing powershell gallery repo  (Bugfix)

* `psrepository` - Fixed the inability to register the powershell gallery repo (Bugfix)

* `package` - Fixed the inability to upgrade previously installed modules with -AllowClobber. This would previously fail with an error if a cmdlet was moved to a new module. Powershell would error stating the cmdlet exists in the system already within a module and you need to specific -AllowClobber to install the new one.  (Bugfix)

* Converted the module over to PDK for validation and spec testing. (Feature)

* Enabled Travis builds (Feature)

* Enabled TLSv1.2 which is required to communicate with PowerShell Gallery. Previously,
  this module did not enforce TLSv1.2 and the repository setup commands would fail. (Bugfix)
  
  Contributed by @pauby

## 2.0.1 (September 6, 2018)

* `package` - Fix error when running with Ruby 1.9.x on the server side ([#16](https://github.com/hbuckle/puppet-powershellmodule/pull/16))

## 2.0.0 (July 7, 2018)

* **New Type:** `pspackageprovider` ([#9](https://github.com/hbuckle/puppet-powershellmodule/pull/9))

* Additional spec tests ([#8](https://github.com/hbuckle/puppet-powershellmodule/pull/8))

* `package` - add :versionable to windowspowershell provider ([#12](https://github.com/hbuckle/puppet-powershellmodule/issues/12))
* `psrepository` - make source_location case sensitive ([#11](https://github.com/hbuckle/puppet-powershellmodule/issues/11))
