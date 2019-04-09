plan profile::my_app::deploy(
  Pattern[/\d+\.\d+\.\d+/] $version,
  TargetSpec $app_servers,
  TargetSpec $db_server,
  TargetSpec $lb_server,
  String[1] $instance = 'my_app',
  Boolean $force = false
) {
  # Validate that there is only a single load balancer server to check
  if get_targets($lb_server).length > 1 {
    fail_plan("${lb_server} did not resolve to a single target")
  }

  # First query the load balancer and make sure the app isn't under too much load to do a deploy.
  unless $force {
    $conns = run_task('profile::lb', $lb_server,
       "Check load before starting deploy",
       action => 'stats',
       backend => $instance,
       server => 'FRONTEND',
    ).first['connections']
    if ($conns > 8) {
      fail_plan("The application has too many open connections: ${conns}")
    } else {
      # Info messages will be displayed when the --verbose flag is used.
      info("Application has ${conns} open connections.")
    }
  }

  # Install the new version of the application and check what version was previously
  # installed so it can be deleted after the deploy.
  $old_versions = run_task('profile::install', [$app_servers, $db_server],
    "Install ${version} of the application",
    version => $version
  ).map |$r| { $r['previous_version'] }

  run_task('profile::migrate', $db_server)

  # Don't log every action on each node, only log important messages
  without_default_logging() || {
    # Expand group references or globs before iterating
    get_targets($app_servers).each |$server| {

      # Check stats and print a message to the user
      $stats = run_task('profile::lb', $lb_server,
        action => 'stats',
        backend => $instance,
        server => $server.name,
        _catch_errors => $force
      ).first
      notice("Deploying to ${server.name}, currently ${stats["status"]} with ${stats["connections"]} open connections.")

      run_task('profile::lb', $lb_server,
        "Drain connections from ${server.name}",
        action => 'drain',
        backend => $instance,
        server => $server.name,
        _catch_errors => $force
      )

      run_task('profile::deploy', [$server],
        "Update application for new version",
      )

      # Verify the app server is healthy before returning it to the load
      # balancer.
      $health = run_task('profile::health_check', $lb_server,
        "Run Healthcheck for ${server.name}",
        target => "http://${server.name}:5000/",
        '_catch_errors' => true).first

      if $health['status'] == 'success' {
        info("Upgrade Healthy, Returning ${server.name} to load balancer")
      } else {
        # Fail the plan unless the app server is healthy or this is a forced deploy
        unless $force {
          fail_plan("Deploy failed on app server ${server.name}: ${health.result}")
        }
      }

      run_task('profile::my_app::lb', $lb_server,
        action => 'add',
        backend => $instance,
        server => $server.name,
        _catch_errors => $force
      )
      notice("Deploy complete on ${server}.")
    }
  }

  run_task('profile::my_app::uninstall', [$db_server, $app_servers],
    "Clean up old versions",
    live_versions => $old_versions + $version,
  )
}
