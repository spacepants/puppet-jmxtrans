#### Table of Contents

1. [Overview](#overview)
1. [Module Description - What the module does and why it is useful](#module-description)
1. [Usage - Configuration options and additional functionality](#usage)
 1. [Installing jmxtrans](#installing-jmxtrans)
 1. [Managing the service](#managing-the-service)
 1. [Configuring servers and queries](#configuring-servers-and-queries)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
 1. [Class: jmxtrans](#class-jmxtrans)
 1. [Defined Type: jmxtrans::query](#defined-type-jmxtrans-query)
 1. [Class: jmxtrans::install (internal)](#class-jmxtrans-install-internal)
 1. [Class: jmxtrans::service (internal)](#class-jmxtrans-service-internal)
1. [Development - Guide for contributing to the module](#development)

## Overview

Configure jmxtrans for collecting and exporting JVM metrics data.

## Module Description

This module supports Puppet 4 only.

This module can be used to install and manage the jmxtrans service, as well as
configure how it connects to JVM processes, what data it pulls out, and where
it sends the data it collects.

For more information on jmxtrans, see [the source repo][jmxtrans-source].

## Usage

By default, the module will do nothing. This is because jmxtrans is not
typically in system packages, so the module does not assume that a package is
available.

For more examples, see the [examples](examples) directory.

### Installing jmxtrans

If you have a repository configured on the system with a `jmxtrans` package
available, you can install jmxtrans by setting the `package_name` parameter on
the main `jmxtrans` class.

~~~puppet
class { '::jmxtrans':
  package_name => 'jmxtrans',
}
~~~

If you have a package available on the local filesystem or remotely over HTTP
(if your package manager supports it), you can set the `package_source`
parameter. Note that if you are on anything other than a Debian or EL-based
operating system, you will also need to set `package_provider`.

~~~puppet
class { '::jmxtrans':
  package_name   => 'jmxtrans',
  package_source => 'http://central.maven.org/maven2/org/jmxtrans/jmxtrans/254/jmxtrans-254.rpm',
}
~~~

### Managing the service

If you want to manage the service, you can set the `service_name` parameter,
which will set `ensure => running` on the service.

~~~puppet
class { '::jmxtrans':
  package_name => 'jmxtrans',
  service_name => 'jmxtrans',
}
~~~

### Configuring servers and queries

The `jmxtrans::query` defined type is used to configure "servers" and "queries"
as described in [the jmxtrans documentation][jmxtrans-docs].

Example usage:

~~~puppet
jmxtrans::query { 'puppetserver':
  host     => 'localhost',
  port     => 1099,
  queries  => [
    {
      object       => "metrics:name=puppetlabs.${facts['hostname']}.compiler.compile",
      attributes   => ['Max', 'Min', 'Mean', 'StdDev', 'Count'],
      result_alias => 'puppetlabs.puppetmaster.compiler.compile',
      writers      => [
        {
          '@class'          => 'com.googlecode.jmxtrans.model.output.KeyOutWriter',
          outputFile        => '/tmp/puppetserver-compile-metrics.txt',
          maxLogFileSize    => '10MB',
          maxLogBackupFiles => '200',
          debug             => true,
        },
      ],
    },
    {
      object       => "metrics:name=puppetlabs.${facts['hostname']}.jruby.num-free-jrubies",
      attributes   => ['Value'],
      result_alias => 'puppetlabs.puppetmaster.jruby.num-free-jrubies',
      writers      => [
        {
          '@class'          => 'com.googlecode.jmxtrans.model.output.KeyOutWriter',
          outputFile        => '/tmp/puppetserver-jruby-metrics.txt',
          maxLogFileSize    => '10MB',
          maxLogBackupFiles => '200',
          debug             => true,
        },
      ],
    },
  ],
}
~~~

This will configure jmxtrans to connect to a JMX RMI on `localhost` listening
on port 1099, and it will:

 - extract the values for `Max`, `Min`, `Mean`, `StdDev`, and `Count` from the
   `metrics:name=puppetlabs.${facts['hostname']}.compiler.compile` object and
   write them to `/tmp/puppetserver-compile-metrics.txt`.
 - extract the value of the `Value` attribute for the object
   `metrics:name=puppetlabs.${facts['hostname']}.jruby.num-free-jrubies` and
   write it to `/tmp/puppetserver-jruby-metrics.txt`.
   
If you intend to use the GraphiteWriter or StdoutWriter on all the objects for
the server, there are top level parameters that you can set which will be
inherited by all the query objects.

## Reference

### Class: jmxtrans

This is the main class for using jmxtrans. It should be included before using
anything else from the module.

#### Parameters

##### `package_name` [String] (optional)

The package to install. Skips managing the package if undef.

##### `service_name` [String] (optional)

The service to manage. Skips managing the service if undef.

##### `package_source` [String] (optional)

A URL or local path to get a package from.

##### `package_provider` [String] (optional)

Used to explicitly set the provider to use to install the package.

##### `config_directory` [String]

Where to place JSON configurations. Defaults to `/var/lib/jmxtrans`.

##### `user` [String]

The user who will own the JSON configurations. Defaults to 'jmxtrans'.

#### Examples

**Example** jmxtrans is installed via some other method

~~~puppet
include ::jmxtrans
~~~

**Example** jmxtrans is available in a repository via the package `jmxtrans`

~~~puppet
class { '::jmxtrans':
  package_name => 'jmxtrans',
  service_name => 'jmxtrans',
}
~~~

**Example** jmxtrans should be installed via rpm installing a remote package

~~~puppet
class { '::jmxtrans':
  package_name  => 'jmxtrans',
  service_name  => 'jmxtrans',
  package_source => 'http://central.maven.org/maven2/org/jmxtrans/jmxtrans/254/jmxtrans-254.rpm',
}
~~~

**Example** jmxtrans runs under a different user with a different config path

~~~puppet
class { '::jmxtrans':
  config_directory => '/etc/jmxtrans/config/',
  user             => 'java',
}
~~~

### Defined Type: jmxtrans::query

This defined type is used to add a JSON configuration for jmxtrans to pull
metrics for a given JVM process and write them out. It can automatically
configure the GraphiteWriter, or you can pass explicit configuration for any
other jmxtrans-supported writer.

#### Parameters

##### `title` [String]
 
The resource title is used for the server `alias`.

##### `ensure` [String]
 
Whether the configuration should exist or not.

##### `host` [String]
 
The host to connect to JMX on. Defaults to `$title`.

##### `port` [Integer]

The port to connect to JMX on.

##### `username` [String] (optional)
 
The username to use to connect to JMX.

##### `password` [String] (optional)
 
The password to use to connect to JMX.

##### `num_threads` [Integer] (optional)
 
How many queries to execute concurrently. Defaults to `undef`, which will
execute the queries serially.

##### `stdout` [Boolean]

Set to `true` to enable the StdoutWriter for each query on this object, so you
don't have to do it manually.

##### `graphite` [Hash] (optional)
 
The Graphite configuration.  Passing a hash with `host` and `port` will
configure the GraphiteWriter for each query on this object, so you don't have to
do it manually. You may also set:

 - `root` [String] to configure the `rootPrefix`
 - `boolean_as_number` [String] to configure the `booleanAsNumber`

##### `queries` [Array]

An array of queries to configure on the object. These consist of hashes of the
form:

~~~
{
  'object'       => 'net.sf.ehcache:typeCacheStatistics,*',
  'attributes'   => [ 'CacheHits', 'CacheMisses', 'ObjectCount' ],
  'type_names'   => ['name'],
  'result_alias' => 'ehcache',
  'writers'      => [
    {
      '@class'            => 'com.googlecode.jmxtrans.model.output.KeyOutWriter',
      'outputFile'        => '/tmp/keyout2.txt',
      'maxLogFileSize'    => '10MB',
      'maxLogBackupFiles' => '200',
      'debug'             => true,
    },
  ],
}
~~~


### Class: jmxtrans::install (internal)

This is an internal class and should not be used directly.

This class is used to install the jmxtrans package. If
`$::jmxtrans::package_name` is undef, then this class will do nothing. If
`$::jmxtrans::package_source` is set, the package will be installed from the
location specified.

This class will use the default provider for a platform if an explicit
value is not set for `$::jmxtrans::package_source`. If a value is set for
at parameter, this class will use the `rpm` provider on RedHat systems and
the `dpkg` provider on Debian systems. This can be overridden by specifying a
value for the `$::jmxtrans::package_provider` parameter.

### Class: jmxtrans::service (internal)

This is an internal class and should not be used directly.

This class manages the jmxtrans service. If `$::jmxtrans::service_name` is
undef, this class does nothing.

## Development

Pull Requests on GitHub are welcome. Please include tests for any new features
or functionality change. See [rspec-puppet] for details on writing unit tests
for Puppet.


[jmxtrans-source]: https://github.com/jmxtrans/jmxtrans
[jmxtrans-docs]: https://github.com/jmxtrans/jmxtrans/wiki/Queries
[rspec-puppet]: http://rspec-puppet.com/
