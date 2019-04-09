plan profile::wordpress_deployment (
  $app_server = 'centos6a.pdx.puppet.vm',
  $db_backend = 'centos7a.pdx.puppet.vm',
  $master = 'master.inf.puppet.vm',
){

  profile::puts("Initiating deployment of Wordpress application on ${app_server}...")

  profile::puts("\tClassifying nodes...")

  run_task('profile::pin_node', "pcp://${master}", group => "db_server", nodename => $db_backend)
  run_task('profile::pin_node', "pcp://${master}", group => "app_server", nodename => $app_server)


  profile::puts("\tCreating database on ${db_backend}")
  profile::puts("\t...Running Puppet Agent on ${db_backend}...")


  $output1 = run_task('profile::puppetagent', "pcp://${db_backend}")
    if $output1.ok() == true {
      profile::puts("\n")
      profile::puts("\tpuppet-agent: ${output1}")

    }
    else {
      fail("${a} failed to run Puppet, failing...")
    }

  profile::puts("\tDeploying Wordpress on ${app_server}")
  profile::puts("\t...Running Puppet Agent on ${app_server}...")

  $output2 = run_task('profile::puppetagent', "pcp://${app_server}")
    if $output2.ok() == true {
      profile::puts("\n")
      profile::puts("\tpuppet-agent: ${output2}")

    }
    else {
        fail("${a} failed to run Puppet, failing...")
    }

  profile::puts("\tRunning healthcheck on ${app_server}...")
    if run_task('profile::wordpress_healthcheck', "pcp://${app_server}",
      port   => 80,
      target => $app_server,
    ).ok() == true {
      profile::puts("\tSuccessfully deployed Wordpress app to ${app_server}!")
    } else {
      fail("\tHealthcheck failed for ${app_server}!")
    }

  profile::puts("Finished deploying Wordpress app on ${app_server}!")

}
~
