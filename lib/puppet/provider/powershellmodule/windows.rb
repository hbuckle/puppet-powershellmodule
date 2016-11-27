Puppet::Type.type(:powershellmodule).provide(:windows) do
  confine :operatingsystem => :windows
  confine :feature => :powershellget
end