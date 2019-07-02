# Class: postfix::spf
#
class postfix::spf {
  require perl::mod::mail::spf

  package { 'postfix-policyd-spf-perl':
    ensure => present,
  }

  file { '/etc/postfix/master.cf':
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    source  => 'puppet:///modules/postfix/master.cf',
    require => Package['postfix-policyd-spf-perl'],
    notify  => Service['postfix'],
  }


}
