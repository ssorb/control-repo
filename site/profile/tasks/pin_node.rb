#!/opt/puppetlabs/puppet/bin/ruby

require 'puppet'
require 'json'
require 'open3'

params = JSON.parse(STDIN.read)
puts("#{params}")
begin

  #cmd_string = %(/usr/local/bin/puppet apply -e "node_group{'"#{params['group']}"':   rule =>  ['and',['=',['fact', 'hostname'],'"#{params['nodename']}"']],}")
  cmd_string = %(/usr/local/bin/puppet apply -e "node_group{'#{params['group']}':   rule =>  ['and',['=',['fact', 'hostname'],'#{params['nodename']}']],}")

  puts("#{cmd_string}")
  _,stdout,stderr,wait_thr = Open3.popen3(cmd_string)
  raise Puppet::Error, stderr if ([wait_thr.value.exitstatus] & [0,2]).empty?
  puts({ status: 'success', message: stdout.readlines.join(''), resultcode: wait_thr.value.exitstatus }.to_json)
  exit 0
rescue Puppet::Error => e
  puts({ status: 'failure', message: "#{e.message}\n#{stderr.readlines.join('')}", resultcode: wait_thr.value.exitstatus }.to_json)
  exit 1
end
