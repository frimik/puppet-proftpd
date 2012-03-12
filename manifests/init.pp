# ProFTPD class
#
# TODO Trigger service restart or reload on config changes.
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
#   Configuration file source url (choose one of source or content)
#
# [*content*]
#   Configuration file content (choose one of source or content)
#
# [*utils*]
#   If set to true (default), will include proftpd-utils package.
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
#   class{'proftpd':
#     ensure        => "running",
#     package       => 'proftpd-mysql',
#     manage_config => true,
#     source        => "puppet://puppet/${module_name}/psftp/proftpd.conf",
#   }
#
# This includes the proftpd class, tells it to install the 'proftpd-mysql'
# package instead of the default 'proftpd'. Config should be managed and the
# configuration file source should be taken from a path in the current module
# (ie, the _including_ module, not the _included_ (proftpd)).
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
  $source = false,
  $content = false,
  $utils = true,
  $utils_package = $proftpd::params::utils_package
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

  if !$content {
    if !$source {
      $template = false
      $real_source = $proftpd::params::source
    } else {
      $template = false
      $real_source = $source
    }
  } else {
    $template = true
    $real_content = $content
  }



  package { $package:
    ensure  => $package_ensure,
  }

  if $utils {
    package { $utils_package:
      ensure => $package_ensure,
    }
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
    if $template {
      file { $config_file:
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0440',
        replace => $config_file_replace,
        content => $real_content,
        require => Package[$package],
      }
    } else {
      file { $config_file:
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0440',
        replace => $config_file_replace,
        source  => $real_source,
        require => Package[$package],
      }
    }
  }

}
