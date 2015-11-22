# Class: postfix::procmail
#
class postfix::procmail {

  package { 'procmail':
    ensure => present,
  }

}
