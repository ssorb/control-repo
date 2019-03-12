class profile::app::cloudshop::webapp::db (
  $dbinstance    = 'MYINSTANCE',
  $dbpass        = lookup('profile::app::cloud shop::webapp::db::dbpass'),
  $dbuser        = 'CloudShop',
  $dbname        = 'AdventureWorks2012',
  $dbserver      = $::hostname, # $::fqdn doesn't work on Windows / AWS
  $file_source   = 'https://s3-us-west-2.amazonaws.com/tseteam/files/sqlwebapp',
){
  profile::app::cloudshop::sqlserver::attachdb { $dbname:
    file_source => $file_source,
    dbinstance  => $dbinstance,
    dbpass      => $dbpass,
    owner       => $dbuser,
  }
}
