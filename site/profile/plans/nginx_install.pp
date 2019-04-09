plan profiles::nginx_install(
     TargetSpec $nodes,
     String $site_content = 'hello!',
   ) {

     # Install the puppet-agent package if Puppet is not detected.
     # Copy over custom facts from the Bolt modulepath.
     # Run the `facter` command line tool to gather node information.
     $nodes.apply_prep

     # Compile the manifest block into a catalog
     apply($nodes) {
       if($facts['os']['family'] == 'redhat') {
         package { 'epel-release':
           ensure => present,
           before => Package['nginx'],
         }
         $html_dir = '/usr/share/nginx/html'
       } else {
         $html_dir = '/var/www/html'
       }

       package {'nginx':
         ensure => present,
       }

       file {"${html_dir}/index.html":
         content => $site_content,
         ensure  => file,
       }

       service {'nginx':
         ensure  => 'running',
         enable  => 'true',
         require => Package['nginx']
       }
     }
   }
