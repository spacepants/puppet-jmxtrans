# This defined type is used to add a JSON configuration for jmxtrans to pull
# metrics for a given JVM process and write them out. It can automatically
# configure the GraphiteWriter, or you can pass explicit configuration for any
# other jmxtrans-supported writer.
#
# @param title [String] The resource title is used for the server `alias`.
#
# @param ensure [String] Whether the configuration should exist or not.
#
# @param host [String] The host to connect to JMX on. Defaults to `$title`.
#
# @param port [Integer] The port to connect to JMX on.
#
# @param username [String] (optional) The username to use to connect to JMX.
#
# @param password [String] (optional) The password to use to connect to JMX.
#
# @param num_threads [Integer] (optional) How many queries to execute
#   concurrently. Defaults to `undef`, which will execute the queries serially.
#
# @param stdout [Boolean] Set to `true` to enable the StdoutWriter for each
#   query on this object, so you don't have to do it manually.
#
# @param pretty [Boolean] Set to `true` to 'pretty print' the json string,
#   rather than an unformatted json blob.
#
# @param graphite [Hash] (optional) The Graphite configuration.  Passing a hash
#   with `host` and `port` will configure the GraphiteWriter for each query on
#   this object, so you don't have to do it manually. You may also set:
#
#   - `root` [String] to configure the `rootPrefix`
#   - `boolean_as_number` [String] to configure the `booleanAsNumber`
#
# @param queries [Array] An array of queries to configure on the object. These
#   consist of hashes of the form:
#
#   ~~~
#   {
#     'object'       => 'net.sf.ehcache:typeCacheStatistics,*',
#     'attributes'   => [ 'CacheHits', 'CacheMisses', 'ObjectCount' ],
#     'type_names'   => ['name'],
#     'result_alias' => 'ehcache',
#     'writers'      => [
#       {
#         '@class'            => 'com.googlecode.jmxtrans.model.output.KeyOutWriter',
#         'outputFile'        => '/tmp/keyout2.txt',
#         'maxLogFileSize'    => '10MB',
#         'maxLogBackupFiles' => '200',
#         'debug'             => true,
#       },
#     ],
#   }
#   ~~~
#
#
define jmxtrans::query (
  Enum['present', 'absent'] $ensure = 'present',

  String[1] $host = $title,
  Optional[Integer[1]] $port = undef,

  Optional[String[1]] $username = undef,
  Optional[String[1]] $password = undef,

  Optional[Integer[1]] $num_threads = undef,

  Boolean $stdout = false,

  Boolean $pretty = false,

  Optional[Struct[{
    host => String[1],
    port => Integer[1],
    Optional[root] => String[1],
    Optional[boolean_as_number] => Boolean,
  }]] $graphite = undef,

  Optional[Array[Struct[{
    object => String[1],
    attributes => Array[String[1]],
    Optional[type_names] => Array[String[1]],
    Optional[result_alias] => String[1],
    Optional[writers] => Array[Hash],
  }]]] $queries = undef,
) {
  include ::jmxtrans

  if $ensure == 'present' {
    if ! $port {
      fail("Must set parameter 'port' on Jmxtrans::Query[${$title}]")
    }
    if ! $queries {
      fail("Must set parameter 'queries' on Jmxtrans::Query[${$title}]")
    }
    $query_list = $queries.reduce([]) |$memo, $value| {

      if $value['writers'] {
        $specific_writers = $value['writers']
      } else {
        $specific_writers = []
      }

      if $graphite {
        $graphite_extras = {
          'rootPrefix'          => $graphite['root'],
          'booleanAsNumber'     => $graphite['boolean_as_number'],
        }
        $graphite_writer = [jmxtrans::merge_notundef({
          '@class' => 'com.googlecode.jmxtrans.model.output.GraphiteWriter',
          'host'   => $graphite['host'],
          'port'   => $graphite['port'],
        }, $graphite_extras)]
      } else {
        $graphite_writer = []
      }

      if $stdout {
        $stdout_writer = [{
          '@class' => 'com.googlecode.jmxtrans.model.output.StdOutWriter',
        }]
      } else {
        $stdout_writer = []
      }

      $writers = $specific_writers + $graphite_writer + $stdout_writer

      if $writers !~ Array[Data, 1] {
        fail("No outputWriter set on jmxtrans::query '${title}' for query object '${value['object']}'")
      }

      $extras = {
        'typeNames'   => $value['type_names'],
        'resultAlias' => $value['result_alias'],
      }

      $memo + [
        jmxtrans::merge_notundef({
          'obj'           => $value['object'],
          'attr'          => $value['attributes'],
          'outputWriters' => $writers,
        }, $extras)
      ]
    }

    $extras = {
      'username'        => $username,
      'password'        => $password,
      'numQueryThreads' => $num_threads,
    }

    $data_hash = {
      'servers' => [
        jmxtrans::merge_notundef({
          'host'    => $host,
          'port'    => "${port}",
          'alias'   => $title,
          'queries' => $query_list,
        }, $extras)
      ],
    }

    file { "${::jmxtrans::config_directory}/${title}.json":
      ensure  => file,
      owner   => $::jmxtrans::user,
      mode    => '0640',
      content => jmxtrans::to_json($data_hash, $pretty),
      require => Class['::jmxtrans::install'],
      notify  => Class['::jmxtrans::service'],
    }
  } else {
    file { "${::jmxtrans::config_directory}/${title}.json":
      ensure  => absent,
      require => Class['::jmxtrans::install'],
      notify  => Class['::jmxtrans::service'],
    }
  }
}
