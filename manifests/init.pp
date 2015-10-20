# == Class: percona
#
# Module for Percona XtraDB management.
#
# === Parameters
#
# [*mysql_version*]
#   The Percona mysql version to be used. Currently 5.5 or 5.6
#
# [*root_password*]
#   The root password of the database
#
# [*old_passwords*]
#   Set this to true to support the old mysql 3.x hashes for the passwords
#
# [*datadir*]
#   The mysql data directory, defaults to /var/lib/mysql
#
# [*port*]
#   The mysql server port, defaults to 3306
#
# [*server_id*]
#   The server id, defaults to 1
#
# [*skip_slave_start*]
#   Set this to true to skip the slave startup on boot
#
# [*ist_recv_addr*]
#   The IST receiver address for WSREP
#
# [*wsrep_max_ws_size*]
#   The WSREP max working set size
#
# [*wsrep_cluster_address*]
#   The WSREP cluster address list, like gcomm://<ip1>:4010,<ip2>:4010
#
# [*wsrep_provider*]
#   The WSREP provider
#
# [*wsrep_max_ws_rows*]
#   The WSREP max working set rows
#
# [*wsrep_sst_receive_address*]
#   The SST receiver address
#
# [*wsrep_slave_threads*]
#   Number of WSREP slave threads
#
# [*wsrep_sst_method*]
#   The WSREP SST method, like rsync or xtrabackup
#
# [*wsrep_sst_auth*]
#   The auth string for SST, if needed
#
# [*wsrep_cluster_name*]
#   The WSREP cluster name
#
# [*binlog_format*]
#   The binlog format
#
# [*default_storage_engine*]
#   The default storage engine
#
# [*innodb_autoinc_lock_mode*]
#   The innodb lock mode
#
# [*innodb_locks_unsafe_for_binlog*]
#   Set this to true if you want to use unsafe locks for the binlogs
#
# [*innodb_buffer_pool_size*]
#   The innodb buffer pool size
#
# [*innodb_log_file_size*]
#   The innodb log file size
#
# [*bulk_insert_buffer_size*]
#   The size of the insert buffer
#
# [*innodb_flush_log_at_trx_commit*]
#   Set this to allow flushing of logs at transaction commit
#
# [*innodb_file_per_table*]
#   Set this to true to allow using sepafate files for the innodb tablespace
#
# [*innodb_file_format*]
#   The file format for innodb
#
# [*innodb_file_format_max*]
#   The higher level of file formats for innodb
#
# [*sort_buffer_size*]
#   The size of the sort buffer
#
# [*read_buffer_size*]
#   The size of the read buffer
#
# [*read_rnd_buffer_size*]
#   The size of the rnd buffer
#
# [*key_buffer_size*]
#   Size for keys
#
# [*myisam_sort_buffer_size*]
#   The myisam sort buffer size
#
# [*thread_cache*]
#   The number of thread caches
#
# [*query_cache_size*]
#   The size of the query cache
#
#
# === Examples
#
#  class { percona:
#    wsrep_cluster_address => 'gcomm://192.168.0.1:4010,192.168.0.2:4010'
#  }
#
# === Authors
#
# Alessandro De Salvo <Alessandro.DeSalvo@roma1.infn.it>
#
# === Copyright
#
# Copyright 2013 Alessandro De Salvo
#
class percona (

/*  $mysql_version                  = $percona::params::mysql_version,
  $root_password                  = $percona::params::root_password,
  $old_passwords                  = $percona::params::old_passwords,
  $datadir                        = $percona::params::datadir,
  $port                           = $percona::params::port,
  $server_id                      = $percona::params::server_id,
  $skip_slave_start               = $percona::params::skip_slave_start,
  $ist_recv_addr                  = $percona::params::ist_recv_addr,
  $wsrep_max_ws_size              = $percona::params::wsrep_max_ws_size,
  $wsrep_cluster_address          = $percona::params::wsrep_cluster_address,
  $wsrep_provider                 = $percona::params::galera_provider,
  $wsrep_max_ws_rows              = $percona::params::wsrep_max_ws_rows,
  $wsrep_sst_receive_address      = $percona::params::wsrep_sst_receive_address,
  $wsrep_slave_threads            = $percona::params::wsrep_slave_threads,
  $wsrep_sst_method               = $percona::params::wsrep_sst_method,
  $wsrep_sst_auth                 = $percona::params::wsrep_sst_auth,
  $wsrep_cluster_name             = $percona::params::wsrep_cluster_name,
  $binlog_format                  = $percona::params::binlog_format,
  $default_storage_engine         = $percona::params::default_storage_engine,
  $innodb_autoinc_lock_mode       = $percona::params::innodb_autoinc_lock_mode,
  $innodb_locks_unsafe_for_binlog = $percona::params::innodb_locks_unsafe_for_binlog,
  $innodb_buffer_pool_size        = $percona::params::innodb_buffer_pool_size,
  $innodb_log_file_size           = $percona::params::innodb_log_file_size,
  $bulk_insert_buffer_size        = $percona::params::bulk_insert_buffer_size,
  $innodb_flush_log_at_trx_commit = $percona::params::innodb_flush_log_at_trx_commit,
  $innodb_file_per_table          = $percona::params::innodb_file_per_table,
  $innodb_file_format             = $percona::params::innodb_file_format,
  $innodb_file_format_max         = $percona::params::innodb_file_format_max,
  $sort_buffer_size               = $percona::params::sort_buffer_size,
  $read_buffer_size               = $percona::params::read_buffer_size,
  $read_rnd_buffer_size           = $percona::params::read_rnd_buffer_size,
  $key_buffer_size                = $percona::params::key_buffer_size,
  $myisam_sort_buffer_size        = $percona::params::myisam_sort_buffer_size,
  $thread_cache                   = $percona::params::thread_cache,
  $query_cache_size               = $percona::params::query_cache_size,
  $thread_concurrency             = $percona::params::thread_concurrency,
  $max_allowed_packet             = $percona::params::max_allowed_packet,
  $log_bin_dir                    = $percona::params::log_bin_dir,
  $log_bin_file                   = $percona::params::log_bin_file,
  $log_slave_updates              = $percona::params::log_slave_updates,
  $log_warnings                   = $percona::params::log_warnings, */

) inherits params {
    class { percona::server:
        mysql_version                  => $mysql_version,
        root_password                  => $root_password,
        old_passwords                  => $old_passwords,
        port                           => $port,
        datadir                        => $datadir,
        server_id                      => $server_id,
        skip_slave_start               => $skip_slave_start,
        ist_recv_addr                  => $ist_recv_addr,
        wsrep_max_ws_size              => $wsrep_max_ws_size,
        wsrep_cluster_address          => $wsrep_cluster_address,
        wsrep_provider                 => $wsrep_provider,
        wsrep_max_ws_rows              => $wsrep_max_ws_rows,
        wsrep_sst_receive_address      => $wsrep_sst_receive_address,
        wsrep_slave_threads            => $wsrep_slave_threads,
        wsrep_sst_method               => $wsrep_sst_method,
        wsrep_sst_auth                 => $wsrep_sst_auth,
        wsrep_cluster_name             => $wsrep_cluster_name,
        binlog_format                  => $binlog_format,
        default_storage_engine         => $default_storage_engine,
        innodb_autoinc_lock_mode       => $innodb_autoinc_lock_mode,
        innodb_locks_unsafe_for_binlog => $innodb_locks_unsafe_for_binlog,
        innodb_buffer_pool_size        => $innodb_buffer_pool_size,
        innodb_log_file_size           => $innodb_log_file_size,
        bulk_insert_buffer_size        => $bulk_insert_buffer_size,
        innodb_flush_log_at_trx_commit => $innodb_flush_log_at_trx_commit,
        innodb_file_per_table          => $innodb_file_per_table,
        innodb_file_format             => $innodb_file_format,
        innodb_file_format_max         => $innodb_file_format_max,
        sort_buffer_size               => $sort_buffer_size,
        read_buffer_size               => $read_buffer_size,
        read_rnd_buffer_size           => $read_rnd_buffer_size,
        key_buffer_size                => $key_buffer_size,
        myisam_sort_buffer_size        => $myisam_sort_buffer_size,
        thread_cache                   => $thread_cache,
        query_cache_size               => $query_cache_size,
        max_allowed_packet             => $max_allowed_packet,
        log_warnings                   => $log_warnings,
    }
}
