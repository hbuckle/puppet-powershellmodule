# The baseline for module testing used by Puppet Labs is that each manifest
# should have a corresponding test manifest that declares that class or defined
# type.
#
# Tests are then run by using puppet apply --noop (to check for compilation
# errors and view a log of events) or by fully applying the test in a virtual
# environment (to compare the resulting system state to the desired state).
#
# Learn more about module testing here:
# https://docs.puppet.com/guides/tests_smoke.html
#
#psrepository { 'PSGallery':
#    ensure              => present,
#    source_location     => 'https://www.powershellgallery.com/api/v2/',
#    installation_policy => 'untrusted',
#}

#resources { 'psrepository':
#    purge => true,
#}

powershellmodule { 'psexcel1':
    ensure     => present,
    version    => '1.0.2',
    repository => 'psgallery',
    name       => 'psexcel',
}

powershellmodule { 'psexcel2':
    ensure  => present,
    version => '1.0.1',
    repository => 'psgallery',
    name => 'psexcel',
}