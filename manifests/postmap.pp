#
# = Define: postfix::postmap
#
define postfix::postmap (
  $source  = undef,
  $content = undef,
  $destdir = '/etc/postfix',
){

  if $content and $source {
    fail('Only one of $content and $source can be specified.')
  }

  if $ensure == 'present' and ! $content and ! $source {
    fail('One of $content and $source must be specified.')
  }

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
