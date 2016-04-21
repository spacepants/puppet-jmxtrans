require 'spec_helper'
require 'json'

fixture_dir = File.expand_path(File.join(__FILE__, '..', '..', 'fixtures', 'data'))

describe 'jmxtrans::query' do
  def check_json_string(expected)
    return Proc.new do |actual|
      begin
        expected_obj = JSON.parse(expected)
        actual_obj = JSON.parse(actual)
        expected_obj == actual_obj
      rescue JSON.ParserError
        false
      end
    end
  end

  context 'jmxtrans::query ensure absent' do
    let(:title) { 'puppetserver' }
    let(:params) {{ :ensure => 'absent' }}

    it { File.write('/tmp/foobar', compile.inspect) }

    it { is_expected.to contain_file('/var/lib/jmxtrans/puppetserver.json').with_ensure('absent') }
  end

  context 'jmxtrans::query minimal' do
    let(:title) { 'puppetserver' }
    let(:params) {{
      :host    => 'w2',
      :port    => 1099,
      :queries => []
    }}

    output = File.read(File.join(fixture_dir, 'minimal.json'))

    it do
      is_expected.to contain_file('/var/lib/jmxtrans/puppetserver.json').with({
        :ensure  => 'file',
        :owner   => 'jmxtrans',
        :mode    => '0640',
        :content => check_json_string(output)
      })
    end
  end

  context 'jmxtrans::query extras' do
    let(:title) { 'puppetserver' }
    let(:params) {{
      :host        => 'w2',
      :port        => 1099,
      :username    => 'user',
      :password    => 'hunter2',
      :num_threads => 2,
      :queries     => []
    }}

    output = File.read(File.join(fixture_dir, 'extras.json'))

    it do
      is_expected.to contain_file('/var/lib/jmxtrans/puppetserver.json').with({
        :ensure  => 'file',
        :owner   => 'jmxtrans',
        :mode    => '0640',
        :content => check_json_string(output)
      })
    end
  end

  context 'jmxtrans::query graphite' do
    let(:title) { 'puppetserver' }
    let(:params) {{
      :host     => 'w2',
      :port     => 1099,
      :graphite => {
        'host' => 'graphite.example.com',
        'port' => 2003,
      },
      :queries  => [{
        'object' => 'java.lang:type=Memory',
        'attributes' => [ 'HeapMemoryUsage', 'NonHeapMemoryUsage' ]
      }]
    }}

    output = File.read(File.join(fixture_dir, 'graphite.json'))

    it do
      is_expected.to contain_file('/var/lib/jmxtrans/puppetserver.json').with({
        :ensure  => 'file',
        :owner   => 'jmxtrans',
        :mode    => '0640',
        :content => check_json_string(output)
      })
    end
  end

  context 'jmxtrans::query stdout' do
    let(:title) { 'puppetserver' }
    let(:params) {{
      :host     => 'w2',
      :port     => 1099,
      :stdout   => true,
      :queries  => [
        {
          'object' => 'java.lang:type=Memory',
          'attributes' => [ 'HeapMemoryUsage', 'NonHeapMemoryUsage' ]
        },
        {
          'object' => 'java.lang:name=CMS Old Gen,type=MemoryPool',
          'attributes' => [ 'Usage' ]
        },
        {
          'object' => 'java.lang:name=ConcurrentMarkSweep,type=GarbageCollector',
          'attributes' => [ 'LastGcInfo' ]
        },
      ]
    }}

    output = File.read(File.join(fixture_dir, 'stdout.json'))

    it do
      is_expected.to contain_file('/var/lib/jmxtrans/puppetserver.json').with({
        :ensure  => 'file',
        :owner   => 'jmxtrans',
        :mode    => '0640',
        :content => check_json_string(output)
      })
    end
  end

  context 'jmxtrans::query multiple writers' do
    let(:title) { 'puppetserver' }
    let(:params) {{
      :host     => 'w2',
      :port     => 1099,
      :stdout   => true,
      :graphite => {
        'host' => 'graphite.example.com',
        'port' => 2003,
      },
      :queries  => [
        {
          'object' => 'java.lang:type=Memory',
          'attributes' => [ 'HeapMemoryUsage', 'NonHeapMemoryUsage' ],
          'writers' => [{
            '@class' => 'com.googlecode.jmxtrans.model.output.KeyOutWriter',
            'settings' => {
              'outputFile' => '/tmp/memory.txt',
              'maxLogFileSize' => '10MB',
              'maxLogBackupFiles' => 200,
              'debug' => true,
            }
          }]
        },
        {
          'object' => 'java.lang:name=CMS Old Gen,type=MemoryPool',
          'attributes' => [ 'Usage' ],
          'result_alias' => 'oldgen',
          'writers' => [{
            '@class' => 'com.googlecode.jmxtrans.model.output.KeyOutWriter',
            'settings' => {
              'outputFile' => '/tmp/oldgen.txt',
              'maxLogFileSize' => '5MB',
              'maxLogBackupFiles' => 50,
              'debug' => false,
            }
          }]
        },
        {
          'object' => 'java.lang:name=ConcurrentMarkSweep,type=GarbageCollector',
          'attributes' => [ 'LastGcInfo' ],
        },
        {
          'object' => 'net.sf.ehcache:typeCacheStatistics,*',
          'attributes'   => [ 'CacheHits', 'CacheMisses', 'ObjectCount' ],
          'type_names'   => ['name'],
          'result_alias' => 'ehcache',
        }
      ]
    }}

    output = File.read(File.join(fixture_dir, 'multiple.json'))

    it do
      is_expected.to contain_file('/var/lib/jmxtrans/puppetserver.json').with({
        :ensure  => 'file',
        :owner   => 'jmxtrans',
        :mode    => '0640',
        :content => check_json_string(output)
      })
    end
  end
end
