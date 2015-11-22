#
# = Define: postfix::postmap
#
define postfix::postmap (
  $source  = undef,
  $content = undef,
  $destdir = '/etc/postfix',
){

  file { "${destdir}/${title}":
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    source  => $source,
    content => $content,
    notify  => Exec["postfix_update_postmap_${title}"],
  }

  exec { "postfix_update_postmap_${title}":
    cwd         => $destdir,
    command     => "/usr/sbin/postmap ${title}",
    refreshonly => true,
    require     => Package['postfix'],
    notify      => Service['postfix'],
  }

}
