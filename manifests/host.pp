# host.pp - the master host of the munin installation
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.

class munin::host(
  $cgi_graphing = false,
  $export_tag = 'munin',
  $notification_email = false,
) {
  package {"munin": ensure => installed, }
  include concat::setup

  Concat::Fragment <<| tag == $export_tag |>>

  concat::fragment{'munin.conf.header':
    target => '/etc/munin/munin.conf',
    content => template('munin/munin.conf.header.erb'),
    order => 05,
  }

  concat{ "/etc/munin/munin.conf":
    owner => root, group => 0, mode => 0644;
  }

  include munin::plugins::muninhost

  if $munin::host::cgi_graphing {
    include munin::host::cgi
  }

  # from time to time we cleanup hanging munin-runs
  file{'/etc/cron.d/munin_kill':
    content => "4,34 * * * * root if $(ps ax | grep -v grep | grep -q munin-run); then killall munin-run; fi\n",
    owner => root, group => 0, mode => 0644;
  }
  if $munin::host::manage_shorewall {
    include shorewall::rules::out::munin
  }
}
