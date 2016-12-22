#
# = Define: postfix::postmap
#
define postfix::postmap (
  $source   = undef,
  $content  = undef,
  $template = undef,
  $destdir  = '/etc/postfix',
){

  if ($source and $content) or ($source and $template) or ($content and $template) {
    fail('Only one of $source, $content and $template can be specified.')
  } elsif ! $source and ! $content and ! $template {
    fail('One of $source, $content or $template must be specified.')
  }

  if ( $template ) {
    $content_real = template($template)
  } else {
    $content_real = $content
  }

  file { "${destdir}/${title}":
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    source  => $source,
    content => $content_real,
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
