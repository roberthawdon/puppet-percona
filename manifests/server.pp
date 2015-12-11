class percona::server (

  $mysql_version                  = $percona::mysql_version,
  $root_password                  = $percona::root_password,
  $old_passwords                  = $percona::old_passwords,
  $datadir                        = $percona::datadir,
  $port                           = $percona::port,
  $server_id                      = $percona::server_id,
  $skip_slave_start               = $percona::skip_slave_start,
  $ist_recv_addr                  = $percona::ist_recv_addr,
  $wsrep_max_ws_size              = $percona::wsrep_max_ws_size,
  $wsrep_cluster_address          = $percona::wsrep_cluster_address,
  $wsrep_provider                 = $percona::galera_provider,
  $wsrep_max_ws_rows              = $percona::wsrep_max_ws_rows,
  $wsrep_sst_receive_address      = $percona::wsrep_sst_receive_address,
  $wsrep_slave_threads            = $percona::wsrep_slave_threads,
  $wsrep_sst_method               = $percona::wsrep_sst_method,
  $wsrep_sst_auth                 = $percona::wsrep_sst_auth,
  $wsrep_cluster_name             = $percona::wsrep_cluster_name,
  $binlog_format                  = $percona::binlog_format,
  $default_storage_engine         = $percona::default_storage_engine,
  $innodb_autoinc_lock_mode       = $percona::innodb_autoinc_lock_mode,
  $innodb_locks_unsafe_for_binlog = $percona::innodb_locks_unsafe_for_binlog,
  $innodb_buffer_pool_size        = $percona::innodb_buffer_pool_size,
  $innodb_log_file_size           = $percona::innodb_log_file_size,
  $bulk_insert_buffer_size        = $percona::bulk_insert_buffer_size,
  $innodb_flush_log_at_trx_commit = $percona::innodb_flush_log_at_trx_commit,
  $innodb_file_per_table          = $percona::innodb_file_per_table,
  $innodb_file_format             = $percona::innodb_file_format,
  $innodb_file_format_max         = $percona::innodb_file_format_max,
  $sort_buffer_size               = $percona::sort_buffer_size,
  $read_buffer_size               = $percona::read_buffer_size,
  $read_rnd_buffer_size           = $percona::read_rnd_buffer_size,
  $key_buffer_size                = $percona::key_buffer_size,
  $myisam_sort_buffer_size        = $percona::myisam_sort_buffer_size,
  $thread_cache                   = $percona::thread_cache,
  $query_cache_size               = $percona::query_cache_size,
  $thread_concurrency             = $percona::thread_concurrency,
  $max_allowed_packet             = $percona::max_allowed_packet,
  $log_bin_dir                    = $percona::log_bin_dir,
  $log_bin_file                   = $percona::log_bin_file,
  $log_slave_updates              = $percona::log_slave_updates,
  $log_warnings                   = $percona::log_warnings,
  $tmpdir                         = $percona::tmpdir,

) inherits params {

  case $::osfamily {
    'RedHat': {
      if ($operatingsystemmajrelease < 7) {
        $percona_compat_packages = [
                                     'Percona-Server-shared-51',
                                   ]
      } else {
        $percona_compat_packages = []
      }
      case $mysql_version {
        '5.6': {
          $percona_galera_package  = 'Percona-XtraDB-Cluster-galera-3'
          $percona_server_packages = [
                                       'Percona-XtraDB-Cluster-server-56',
                                       'percona-xtrabackup'
                                     ]
          $percona_client_packages = [ 'Percona-XtraDB-Cluster-client-56' ]
        }
        default: {
          $percona_galera_package  = 'Percona-XtraDB-Cluster-galera-2'
          $percona_server_packages = [
                                       'Percona-XtraDB-Cluster-server-55',
                                       'percona-xtrabackup'
                                     ]
          $percona_client_packages = [ 'Percona-XtraDB-Cluster-client-55' ]
        }
      }
    }
    'Debian': {
      case $mysql_version {
        '5.6': {
          $percona_galera_package  = 'percona-xtradb-cluster-galera-3.x'
          $percona_server_packages = [
                                       'percona-xtradb-cluster-server-5.6',
                                       'percona-xtrabackup'
                                     ]
          $percona_client_packages = [ 'percona-xtradb-cluster-client-5.6' ]
        }
        default: {
          $percona_galera_package  = 'percona-xtradb-cluster-galera-2.x'
          $percona_server_packages = [
                                       'percona-xtradb-cluster-server-5.5',
                                       'percona-xtrabackup'
                                     ]
          $percona_client_packages = [ 'percona-xtradb-cluster-client-5.5' ]
        }
      }
    }
    default:   {
    }
  }

  if ($percona_compat_packages) {
      package { $percona_compat_packages: require => $percona::params::percona_repo }
      $percona_server_req = Package[$percona_compat_packages]
  } else {
      $percona_server_req = $percona::params::percona_repo
  }
  package { $percona_galera_package:  require => $percona_server_req }
  package { $percona_server_packages: require => Package[$percona_galera_package] }
  package { $percona_client_packages: require => Package[$percona_server_packages] }

  exec { "init percona db":
      command => "mysql_install_db",
      path    => [ '/bin', '/usr/bin' ],
      unless  => "test -f ${datadir}/${percona::params::percona_host_table}",
      require => [File[$percona::params::percona_conf],File[$datadir],Package[$percona_server_packages]],
      timeout => 0
  }

  $wsrep_provider_options = "gcache.size=${wsrep_max_ws_size}; gmcast.listen_addr=tcp://0.0.0.0:4010; ist.recv_addr=${ist_recv_addr}; evs.keepalive_period = PT3S; evs.inactive_check_period = PT10S; evs.suspect_timeout = PT30S; evs.inactive_timeout = PT1M; evs.install_timeout = PT1M;"

  file {$percona::params::percona_conf:
      content => template('percona/my.cnf.erb'),
      require => Package[$percona_server_packages],
      notify  => Service[$percona::params::percona_service]
  }

  file {$datadir:
      ensure => directory,
      owner  => mysql,
      group  => mysql,
      require => Package[$percona_server_packages],
      notify  => Service[$percona::params::percona_service]
  }

  file {$tmpdir:
      ensure => directory,
      owner  => mysql,
      group  => mysql,
      require => Package[$percona_server_packages],
      notify  => Service[$percona::params::percona_service]
      }

  file {$log_bin_dir:
      ensure => directory,
      owner  => mysql,
      group  => mysql,
      require => Package[$percona_server_packages],
      notify  => Service[$percona::params::percona_service]
  }

  service { $percona::params::percona_service:
      ensure => running,
      enable => true,
      hasrestart => true,
      require => [File[$percona::params::percona_conf],Package[$percona_client_packages],Exec["init percona db"],File[$datadir]],
  }

  if ($root_password) {
      exec {"set-percona-root-password":
          command => "mysqladmin -u root password \"$root_password\"",
          path    => ["/usr/bin"],
          onlyif  => "mysqladmin -u root status 2>&1 > /dev/null",
          require => Service [$percona::params::percona_service]
      }
  }

}
