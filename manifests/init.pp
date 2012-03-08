# ProFTPD class
#
# == Parameters
#
# Document parameters here
#
# [*ensure*]
#   ensure parameter must be 'running', 'present', 'stopped' or 'absent'.
#   Defaults to 'running'. The various settings controls not only the package,
#   but also the service and configuration states.
#
# [*autoupgrade*]
#   If set to true, will ensure latest package is always installed.
#
# [*package*]
#   The name of the package to manage. Defaults to 'proftpd'.
#
# [*config_file*]
#   The configuration file. Defaults to '/etc/proftpd.conf'.
#
# [*config_file_replace*]
#   Whether or not the configuration file should be replaced or used strictly
#   for initialization purposes.
#
# [*manage_config*]
#   Whether the config file is managed at all.
#
# [*source*]
#   Configuration file source url
#
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
  $ensure = 'running',
  $autoupgrade = false,
  $package = $proftpd::params::package,
  $config_file = $proftpd::params::config_file,
  $config_file_replace = true,
  $manage_config = true,
  $source = $proftpd::params::source
) inherits proftpd::params {

  case $ensure {
    'running': {
      $dir_ensure = 'directory'
      $service_ensure = 'running'
      if $autoupgrade == true {
        $package_ensure = 'latest'
      } else {
        $package_ensure = 'present'
      }
    }
    'present': {
      $dir_ensure = 'directory'
      $service_ensure = undef
      $package_ensure = 'present'
    }
    'stopped': {
      $dir_ensure = 'directory'
      $service_ensure = 'stopped'
      $package_ensure = 'present'
    }

    'absent': {
      $dir_ensure = 'absent'
      $package_ensure = 'absent'
    }
    default: {
      fail("ensure parameter must be 'running', 'present', 'stopped' or 'absent'")
    }
  }

  package { $package:
    ensure  => $package_ensure,
  }

  service { "proftpd":
    ensure    => $service_ensure,
    enable      => $service_ensure ? {
      'present' => undef,
      'running' => true,
      'stopped' => false,
    },
    hasstatus  => true,
  }

  if $manage_config {
    file { $config_file:
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0440',
      replace => $config_file_replace,
      source  => $source,
      require => Package[$package],
    }
  }

}
