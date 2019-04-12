class profile::platform::baseline::windows::packages {

  Package {
    ensure   => installed,
    provider => chocolatey,
  }

  #package { 'notepadplusplus': }
  package { '7zip': }
  package { 'git': }
  package { 'uniextract': }
  package { 'firefox': }

#  reboot {'post_install_reboot':
#    subscribe => Package['firefox'],
#    apply     => 'immediately',
#    timeout   => 0,
#  }


}
