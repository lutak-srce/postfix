#
# = Class: postfix::params
#
# This module contains defaults for postfix modules
#
class postfix::params {

  $ensure           = 'present'
  $version          = undef
  $status           = 'enabled'
  $file_mode        = '0644'
  $file_owner       = 'root'
  $file_group       = 'root'
  $autorestart      = true
  $dependency_class = 'postfix::dependency'
  $my_class         = undef

  # install package depending on major version
  case $::osfamily {
    default: {}
    /(RedHat|redhat|amazon)/: {
      $package         = 'postfix'
      $service         = 'postfix'
      $file_maincf     = '/etc/postfix/main.cf'
      $template_maincf = 'postfix/rhel_main.cf.erb'
    }
    /(Debian|debian)/: {
      $package         = 'postfix'
      $service         = 'postfix'
      $file_maincf     = '/etc/postfix/main.cf'
      $template_maincf = 'postfix/debian_main.cf.erb'
    }
  }

}
