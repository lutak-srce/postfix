# Class: postfix::saslauthd
#
class postfix::saslauthd {
  package { 'cyrus-sasl':
    ensure  => present,
  }

  service { 'saslauthd':
    ensure  => running,
    enable  => true,
    require => Package['cyrus-sasl'],
  }
}
