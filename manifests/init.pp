# ProFTPD class
#
# == Parameters
#
# Document parameters here
#
# [*servers*]
#   Description of servers class parameter.  e.g. "Specify one or more
#   upstream ntp servers as an array."
#
# == Variables
#
# Here you should define a list of variables that this module would require.
#
# [*$enc_ntp_servers*]
#     Description of this variable.  e.g. "The parameter enc_ntp_servers
# must be set by the External Node Classifier as a comma separated list of
# hostnames."  (Note, global variables should not be used in preference to
# class parameters as of Puppet 2.6.)
#
# == Examples
#
# Put some examples on how to use your class here.
#
#   $example_var = "blah"
#   include example_class
#
# == Authors
#
# Mikael Fridh <mfridh@marinsoftware.com>
#
# == Copyright
#
# Copyright 2012 Marin Software Inc, unless otherwise noted.
#
class proftpd (
  $ensure = 'present',
  $autoupgrade = false,
  $package = $proftpd::params::package,
  $config_file = $proftpd::params::config_file,
  $config_file_replace = true,
  $manage_config = true,
  $source = $proftpd::params::source
) inherits proftpd::params {

  case $ensure {
    'present': {
      $dir_ensure = 'directory'
      if $autoupgrade == true {
        $package_ensure = 'latest'
      } else {
        $package_ensure = 'present'
      }
    }
    'absent': {
      $package_ensure = 'absent'
      $dir_ensure = 'absent'
    }
    default: {
      fail('ensure parameter must be present or absent')
    }
  }

  package { $package:
    ensure  => $package_ensure,
  }

  if $manage_config {
    file { $config_file:
      ensure  => $ensure,
      owner   => 'root',
      group   => 'root',
      mode    => '0440',
      replace => $config_file_replace,
      source  => $source,
      require => Package[$package],
    }
  }

}
