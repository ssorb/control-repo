# class to make a windows host join a AD domain
class profile::platform::baseline::windows::join_domain {

  class { 'domain_membership':
    domain       => lookup('profile::platform::baseline::windows::join_domain::name'),
    username     => lookup('profile::platform::baseline::windows::join_domain::join_user'),
    password     => lookup('profile::platform::baseline::windows::join_domain::join_password'),
    join_options => '3',
  }
}
