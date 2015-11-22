#
# = Define: postfix::aliases
#
define postfix::aliases (
  $source  = undef,
  $content = undef,
  $destdir = '/etc',
) {

  include ::postfix

  file { "${destdir}/${title}":
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    source  => $source,
    content => $content,
    notify  => Exec["postfix_update_aliases_${title}"],
  }

  exec { "postfix_update_aliases_${title}":
    cwd         => $destdir,
    command     => "/usr/bin/newaliases ${title}",
    refreshonly => true,
    require     => Package['postfix'],
    notify      => Service['postfix'],
  }

}
