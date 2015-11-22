#
# = Class: postfix
#
# This class manages Postfix MTA
#
#
# == Parameters
#
# [*ensure*]
#   Type: string, default: 'present'
#   Manages package installation and class resources. Possible values:
#   * 'present' - Install package, ensure files are present (default)
#   * 'absent'  - Stop service and remove package and managed files
#
# [*package*]
#   Type: string, default on $::osfamily basis
#   Manages the name of the package.
#
# [*version*]
#   Type: string, default: undef
#   If this value is set, the defined version of package is installed.
#   Possible values are:
#   * 'x.y.z' - Specific version
#   * latest  - Latest available
#
# [*service*]
#   Type: string, defaults on $::osfamily basis
#   Name of the backup (or archive) service. Defaults are provided on
#   $::osfamily basis.
#
# [*status*]
#   Type: string, default: 'enabled'
#   Define the provided service status. Available values affect both the
#   ensure and the enable service arguments:
#   * 'enabled':     ensure => running, enable => true
#   * 'disabled':    ensure => stopped, enable => false
#   * 'running':     ensure => running, enable => undef
#   * 'stopped':     ensure => stopped, enable => undef
#   * 'activated':   ensure => undef  , enable => true
#   * 'deactivated': ensure => undef  , enable => false
#   * 'unmanaged':   ensure => undef  , enable => undef
#
# [*file_mode*]
# [*file_owner*]
# [*file_group*]
#   Type: string, default: '0644'
#   Type: string, default: 'root'
#   Type: string, default 'root'
#   File permissions and ownership information assigned to config files.
#
# [*file_maincf*]
#   Type: string, default on $::osfamily basis
#   Path to main.cf
#
# [*interfaces*]
#   Type: array, default: ['localhost']
#   Defines list of interfaces postfix will bind to.
#
# [*inet_protocols*]
#   Type: string, default: 'ipv4'
#   Defines the protocols postfix will support
#
# [*mydestination*]
#   Type: array, default: [ '$myhostname', 'localhost.$mydomain', 'localhost' ]
#   Defines list of hostnames/domains which will be used as 'mydestination'
#
# [*mynetworks*]
#   Type: array, default: []
#   Specifies the list of "trusted" SMTP clients that have more privileges.
#
# [*recipient_canonical_maps*]
#   Type: string, default: undef
#   Specifies the path to a file that stores recipient canonical maps.
#   File must be hashed.
#
# [*smtpd_client_restrictions*]
#   Type: array, default: []
#   Optional restrictions that the Postfix SMTP server applies in the context
#   of a client connection request.
#
# [*smtpd_recipient_restrictions*]
#   Type: array, default: []
#   Optional restrictions that the Postfix SMTP server applies in the context
#   of a client RCPT TO command, after smtpd_relay_restrictions.
#
# [*smtpd_banner*]
#   Type: string, default: '$myhostname ESMTP $mail_name'
#   Sets HELLO banner that will MTA show to its clients.
#
# [*relayhost*]
#   Type: string, default: ''
#   Sets relayhost for delivering messages.
#
# [*my_class*]
#   Type: string, default: undef
#   Name of a custom class to autoload to manage module's customizations
#
# [*noops*]
#   Type: boolean, default: undef
#   Set noop metaparameter to true for all the resources managed by the module.
#   If true no real change is done is done by the module on the system.
#
class postfix (
  $ensure                       = present,
  $package                      = $::postfix::params::package,
  $version                      = undef,
  $service                      = $::postfix::params::service,
  $status                       = 'enabled',
  $file_mode                    = $::postfix::params::file_mode,
  $file_owner                   = $::postfix::params::file_owner,
  $file_group                   = $::postfix::params::file_group,
  $file_maincf                  = $::postfix::params::file_maincf,
  $template_maincf              = $::postfix::params::template_maincf,
  $interfaces                   = [ 'localhost' ],
  $inet_protocols               = 'all',
  $mydestination                = [ '$myhostname', 'localhost.$mydomain', 'localhost' ],
  $mynetworks                   = [],
  $recipient_canonical_maps     = undef,
  $smtpd_client_restrictions    = [],
  $smtpd_recipient_restrictions = [],
  $smtpd_banner                 = '$myhostname ESMTP $mail_name',
  $relayhost                    = 'UNSET',
  $my_class                     = undef,
  $noops                        = undef,
  ) inherits postfix::params {

  ### Input parameters validation
  validate_re($ensure, ['present','absent'], 'Valid values are: present, absent')
  validate_string($package)
  validate_string($version)
  validate_string($service)
  validate_re($status,  ['enabled','disabled','running','stopped','activated','deactivated','unmanaged'], 'Valid values are: enabled, disabled, running, stopped, activated, deacti
vated and unmanaged')

  ### Internal variables (that map class parameters)
  if $ensure == 'present' {
    $package_ensure = $version ? {
      ''      => 'present',
      default => $version,
    }
    $service_enable = $status ? {
      'enabled'     => true,
      'disabled'    => false,
      'running'     => undef,
      'stopped'     => undef,
      'activated'   => true,
      'deactivated' => false,
      'unmanaged'   => undef,
    }
    $service_ensure = $status ? {
      'enabled'     => 'running',
      'disabled'    => 'stopped',
      'running'     => 'running',
      'stopped'     => 'stopped',
      'activated'   => undef,
      'deactivated' => undef,
      'unmanaged'   => undef,
    }
    $file_ensure = present
  } else {
    $package_ensure = 'absent'
    $backup_service_enable = undef
    $backup_service_ensure = stopped
    $archive_service_enable = undef
    $archive_service_ensure = stopped
    $file_ensure    = absent
  }

  ### Extra classes
  if $my_class         { include $my_class         }

  package { 'postfix':
    ensure => $package_ensure,
    name   => $package,
    noop   => $noops,
  }

  service { $service :
    ensure  => $service_ensure,
    enable  => $service_enable,
    require => Package['postfix'],
    noop    => $noops,
  }

  # set defaults for file resource in this scope.
  File {
    ensure  => $file_ensure,
    owner   => $file_owner,
    group   => $file_group,
    mode    => $file_mode,
    require => Package['postfix'],
    noop    => $noops,
  }

  file { '/etc/postfix/main.cf':
    path    => $file_maincf,
    content => template($template_maincf),
    notify  => Service[$service],
  }

  # autoload postmaps
  $postfix_postmaps = hiera_hash('postfix::postmaps', {})
  create_resources(::Postfix::Postmap, $postfix_postmaps)

}
# vi:syntax=puppet:filetype=puppet:ts=4:et:nowrap:
