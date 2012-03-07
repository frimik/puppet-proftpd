class proftpd::params {

  case $::operatingsystem {
    centos, redhat, oel, scientific: {
      $package = "proftpd"
      $config_file = "/etc/proftpd.conf"
      $source = "puppet://puppet/${module_name}/proftpd.conf"
    }
    default: {
      fail ("The ${module_name} module is not supported on ${operatingsystem}")
    }
  }

}
