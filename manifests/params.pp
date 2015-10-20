class percona::params {

  $mysql_version                  = "5.5"
  $root_password                  = undef
  $old_passwords                  = false
  $datadir                        = "/var/lib/mysql"
  $server_id                      = 1
  $skip_slave_start               = true
  $ist_recv_addr                  = $ipaddress
  $wsrep_max_ws_size              = "2G"
  $wsrep_cluster_address          = "gcomm://"
  $wsrep_max_ws_rows              = 1024000
  $wsrep_sst_receive_address      = "${ipaddress}:4020"
  $wsrep_slave_threads            = 2
  $wsrep_sst_method               = "rsync"
  $wsrep_sst_auth                 = undef
  $wsrep_cluster_name             = "default"
  $binlog_format                  = "ROW"
  $default_storage_engine         = "InnoDB"
  $innodb_autoinc_lock_mode       = 2
  $innodb_locks_unsafe_for_binlog = 1
  $innodb_buffer_pool_size        = "128M"
  $innodb_log_file_size           = "256M"
  $bulk_insert_buffer_size        = "128M"
  $innodb_flush_log_at_trx_commit = 2
  $innodb_file_per_table          = true
  $innodb_file_format             = "Barracuda"
  $innodb_file_format_max         = "Barracuda"
  $sort_buffer_size               = "64M"
  $read_buffer_size               = "64M"
  $read_rnd_buffer_size           = "64M"
  $key_buffer_size                = "64M"
  $myisam_sort_buffer_size        = "64M"
  $thread_cache                   = "2"
  $query_cache_size               = "64M"
  $thread_concurrency             = 2
  $max_allowed_packet             = "128M"
  $log_bin_dir                    = undef
  $log_bin_file                   = undef
  $log_slave_updates              = undef

  case $::osfamily {
    'RedHat': {
      $percona_conf = '/etc/my.cnf'
      $galera_provider = '/usr/lib64/libgalera_smm.so'
      $percona_host_table = "mysql/user.frm"
      $percona_service = 'mysql'
      yumrepo { "Percona":
          descr    => "CentOS \$releasever - Percona",
          baseurl  => "http://repo.percona.com/centos/$operatingsystemmajrelease/os/\$basearch/",
          enabled  => 1,
          gpgkey   => "http://www.percona.com/downloads/RPM-GPG-KEY-percona",
          gpgcheck => 1
      }
      $percona_repo = Yumrepo['Percona']
    }
    'Debian': {
      $percona_conf = '/etc/mysql/my.cnf'
      $galera_provider = '/usr/lib/libgalera_smm.so'
      $percona_host_table = "mysql/user.frm"
      $percona_service = 'mysql'
      $percona_keyprefix = "1C4CBDCD"
      $percona_keynum = "CD2EFD2A"
      exec {"import Percona key":
          path    => ['/bin', '/usr/bin'],
          command => "apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ${percona_keyprefix}${percona_keynum}",
          unless  => "apt-key export ${percona_keynum} 2>/dev/null | gpg - 2>/dev/null > /dev/null"
      }
      file {'/etc/apt/sources.list.d/percona.list':
          content => template('percona/percona.list.erb'),
          require => Exec["import Percona key"],
          notify  => Exec["apt update percona"]
      }
      exec {'apt update percona':
          path        => ['/bin', '/usr/bin'],
          command     => 'apt-get update',
          require     => File['/etc/apt/sources.list.d/percona.list'],
          refreshonly => true
      }
      $percona_repo = Exec['apt update percona']
    }
    default:   {
    }
  }

}
