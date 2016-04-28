# This is an example manifest that configures pe-puppetserver and jmxtrans to
# push JMX metrics from the pe-puppetserver instance into Graphite. A similar
# thing could be done for the FOSS build of puppetserver, but as of this
# writing none of the puppetserver-specific metrics are available in the FOSS
# build. SERVER-1259 captures the intent to make these public.
#

# This is where PE configures the JAVA_ARGS for pe-puppetserver. You would
# actually want to set this in hiera or the PE Node Classifier, or manually
# manage the default JAVA_ARGS for the service some other way.
class { '::puppet_enterprise::profile::master':
  java_args => {
    'Dcom.sun.management.jmxremote.port'         =>  '=1099',
    'Dcom.sun.management.jmxremote.authenticate' => '=false',
    'Dcom.sun.management.jmxremote.ssl'          => '=false',
  }
}

# This assumes that you have already placed the jmxtrans package into some repo
# configured on the node in question. Neither EL nor Debian has a jmxtrans
# package in its repository as of the time of this writing, and the project
# does not provide a repository either.
class { '::jmxtrans':
  package_name => 'jmxtrans',
  service_name => 'jmxtrans',
}

# This is declared here just for convenience. Note the `root` parameter: that
# will create all these metrics under the tree `jmxtrans.hostname`.
$graphite = {
  host => 'graphite.example.com',
  port => 2003,
  root => "jmxtrans.${facts['hostname']}",
}

# Puppet Server provides a few different "types" of metrics, which have
# different attributes available. "Count" and "Value" are the only available
# attribute for their respective metrics, but the histogram metrics have more
# available than listed here, but to avoid clutter and wasted resources, I only
# have those metrics configured to pull out what I find the most useful subset.
$count = ['Count']
$value = ['Value']
$histo = ['Max', 'Min', 'Mean', 'StdDev', 'Count', '50thPercentile', '75thPercentile', '95thPercentile', '99thPercentile']

# These are far from all the metrics available in puppetserver, but they seem
# the most generally useful. Much of the other metrics are per-node or
# per-environment, and collecting all these overwhelms Graphite, as many PE
# users have learned. There are internal tickets capturing this problem.
$attributes = {
  'compiler.compile'               => $histo,
  'compiler.compile.production'    => $histo,
  'compiler.evaluate_ast_node'     => $histo,
  'compiler.evaluate_main'         => $histo,
  'compiler.evaluate_node_classes' => $histo,
  'compiler.evaluate_definitions'  => $histo,
  'compiler.evaluate_generators'   => $histo,
  'compiler.finish_catalog'        => $histo,
  'compiler.set_node_params'       => $histo,
  'compiler.create_settings_scope' => $histo,
  'http.active-requests'           => $count,
  'http.active-histo'              => $histo,
  'http.total-requests'            => $histo,
  'jruby.borrow-count'             => $count,
  'jruby.borrow-retry-count'       => $count,
  'jruby.borrow-timeout-count'     => $count,
  'jruby.borrow-timer'             => $histo,
  'jruby.free-jrubies-histo'       => $histo,
  'jruby.num-free-jrubies'         => $value,
  'jruby.num-jrubies'              => $value,
  'jruby.request-count'            => $count,
  'jruby.requested-jrubies-histo'  => $histo,
  'jruby.return-count'             => $count,
  'jruby.wait-timer'               => $histo,
}

# Since the structure of these query hashes are so similar, we simplify things
# by defining the hash above, which contains the only data that changes between
# the queries and then we use Puppet 4 functions to generate a list of hashes
# that we can feed to jmxtrans::query.
$puppetserver_queries = $attributes.reduce([]) |$memo, $val| {
  $obj_name = $val[0]
  $obj_attr = $val[1]
  $memo + [{
    object       => "metrics:name=puppetlabs.${facts['hostname']}.${obj_name}",
    attributes   => $obj_attr,
    result_alias => "puppetlabs.${obj_name}",
  }]
}

# It is also useful to collect some core JVM metrics. This would work even on
# FOSS currently, although this data is not quite as useful as the metrics
# specific to puppetserver.
$jvm_queries = [
  {
    object       => 'java.lang:type=ClassLoading',
    attributes   => ['LoadedClassCount', 'TotalLoadedClassCount', 'UnloadedClassCount'],
    result_alias => 'lang.ClassLoading',
  },
  {
    object       => 'java.lang:type=GarbageCollector,*',
    type_names   => ['name'],
    attributes   => ['LastGcInfo'],
    result_alias => 'lang.GarbageCollector',
  },
  {
    object       => 'java.lang:type=Memory',
    attributes   => ['HeapMemoryUsage', 'NonHeapMemoryUsage'],
    result_alias => 'lang.Memory',
  },
  {
    object       => 'java.lang:type=Runtime',
    attributes   => ['Uptime'],
    result_alias => 'lang.Runtime',
  },
  {
    object       => 'java.lang:type=Threading',
    attributes   => ['ThreadCount', 'TotalStartedThreadCount', 'PeakThreadCount'],
    result_alias => 'lang.Threading',
  },
]

$queries = $puppetserver_queries + $jvm_queries

jmxtrans::query { 'puppetserver':
  host     => $facts['fqdn'],
  port     => 1099,
  graphite => $graphite,
  queries  => $queries,
}
