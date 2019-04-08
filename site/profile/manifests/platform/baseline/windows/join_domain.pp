# class to make a windows host join a AD domain
class profile::platform::baseline::windows::join_domain {

  class { 'domain_membership':
    domain       => lookup('awskit::windows_domain::name'),
    username     => lookup('awskit::windows_domain::join_user'),
    password     => lookup('awskit::windows_domain::join_password'),
    join_options => '3',
  }
}
