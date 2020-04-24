## 2.0.2 (April 24, 2020)

BUG FIXES:

	* `psrepository` fixes:
	- Fixes the inability to register psrepoositorys when none are registered on the node prior to puppet due to bug in `instances_command` expecting a returned hashtable.
	- Many fixes around the default powershell gallery repo due to the `flush` command attempting to set the source_location of the repo:
	-- Fixes the inability to change the installation policy of a pre-existing powershell gallery repo
	-- Fixes the inability to register the powershell gallery repo

	* `package` fixes:
	-  Fixes the inability to upgrade previously installed modules with -AllowClobber. This would previously fail with an error if a cmdlet was moved to a new module. Powershell would error stating the cmdlet exists in the system already within a module and you need to specific -AllowClobber to install the new one.


## 2.0.1 (September 6, 2018)

BUG FIXES:

* `package` - Fix error when running with Ruby 1.9.x on the server side ([#16](https://github.com/hbuckle/puppet-powershellmodule/pull/16))

## 2.0.0 (July 7, 2018)

FEATURES:

* **New Type:** `pspackageprovider` ([#9](https://github.com/hbuckle/puppet-powershellmodule/pull/9))

IMPROVEMENTS:

* Additional spec tests ([#8](https://github.com/hbuckle/puppet-powershellmodule/pull/8))

BUG FIXES:

* `package` - add :versionable to windowspowershell provider ([#12](https://github.com/hbuckle/puppet-powershellmodule/issues/12))
* `psrepository` - make source_location case sensitive ([#11](https://github.com/hbuckle/puppet-powershellmodule/issues/11))
