class profile::platform::baseline::windows::bootstrap2 {

  require ::chocolatey
  Package {
      ensure   => installed,
      provider => chocolatey,
    }

  Reboot {
      timeout   => 0,
  }

  $motd = @("MOTD"/L)
    ===========================================================

          Welcome to ${::hostname}

    Access  to  and  use of this server is  restricted to those
    activities expressly permitted by the system administration
    staff. If you are not sure if it is allowed, then DO NOT DO IT.

    ===========================================================

    The operating system is: ${::operatingsystem}
            The domain is: ${::domain}

    | MOTD
    
  $message = lookup('motd', String, 'first', $motd)

  registry_value { 'HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\policies\system\legalnoticecaption':
    ensure => present,
    type   => string,
    data   => 'Message of the day',
  }

  registry_value { 'legalnoticetext':
    path => 'HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\policies\system\legalnoticetext',
    ensure => present,
    type   => string,
    data   => $message,
  }

  registry::value { 'enable insecure winrm':
    key    => 'HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WinRM\Service',
    value  => 'AllowUnencryptedTraffic',
    data   => '1',
    type   => 'dword',
    require => Registry::Value['legalnoticetext'],
    notify => Service['WinRM'],
  }

  service { 'WinRM':
    ensure => 'running',
    enable => true,
  }

  dsc_file { 'first.txt':
      dsc_ensure         => 'present',
      dsc_type            => 'file',
      dsc_contents        => 'This resource triggers the FIRST reboot',
      dsc_destinationpath => 'C:\Users\Administrator\Desktop\first.txt',
      dsc_attributes      => ['ReadOnly'],
      require             => Registry::Value['enable insecure winrm'],
      notify              => Reboot['after_first_txt'],
    }

 reboot { 'after_first_txt':
    subscribe     => Dsc_file['first.txt'],
  }

  dsc_file { 'second.txt':
      dsc_ensure         => 'present',
      dsc_type            => 'file',
      dsc_contents        => 'This resource triggers the SECOND reboot',
      dsc_destinationpath => 'C:\Users\Administrator\Desktop\second.txt',
      dsc_attributes      => ['ReadOnly'],
      require             => Dsc_file['first.txt'],
      notify              => Reboot['after_second_txt'],
    }

  package { 'notepadplusplus': 
    require => Dsc_file['second.txt'],
  }
 
  package { '7zip': 
    require => Package['notepadplusplus'],
  }

  package { 'git': 
   require => Package['7zip'],
  }

  package { 'firefox': 
    require => Package['git'],
    notify  => Reboot['post_package_install'],
  }

  reboot { 'post_package_install': }


}
