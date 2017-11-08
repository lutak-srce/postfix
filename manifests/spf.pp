#
# Class: postfix::spf
#
class postfix::spf {
  require perl::mod::mail::spf

  package { 'postfix-policyd-spf-perl':
    ensure => present,
  }
}
