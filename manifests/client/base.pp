class munin::client::base {
  service { 'munin-node':
    ensure => running,
    enable => true,
    hasstatus => true,
    hasrestart => true,
  }
  file {'/etc/munin':
    ensure => directory,
    mode => 0755, owner => root, group => 0;
  }
  file {'/etc/munin/munin-node.conf':
    content => template("munin/munin-node.conf.${::operatingsystem}"),
    notify => Service['munin-node'],
    mode => 0644, owner => root, group => 0,
  }
  munin::register { $munin::client::host ? {
      '*'      => $::fqdn,
      default  => $munin::client::host
    }:  
    host       => $munin::client::host ? {
      '*'      => $::fqdn,
      default  => $munin::client::host
    },
    port       => $munin::client::port,
    use_ssh    => $munin::client::use_ssh,
    config     => [ 'use_node_name yes' ],
    export_tag => $munin::client::export_tag,
    warnings   => $munin::client::warnings,
    critical   => $munin::client::critical,
  }
  include munin::plugins::base
}
