require 'spec_helper'

describe 'jmxtrans' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context 'on #{os}' do
        let(:facts) do
          facts
        end

        context 'jmxtrans class without any parameters' do
          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('jmxtrans::install') }
          it { is_expected.to contain_class('jmxtrans::service').that_subscribes_to('jmxtrans::install') }

          it { is_expected.not_to contain_package('jmxtrans') }
          it { is_expected.not_to contain_service('jmxtrans') }
        end

        context 'jmxtrans class with package name' do
          let(:params) {{
            :package_name => 'jmxtrans',
          }}

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('jmxtrans::install') }
          it { is_expected.to contain_class('jmxtrans::service').that_subscribes_to('jmxtrans::install') }

          it { is_expected.to contain_package('jmxtrans').with_ensure('present') }
          it { is_expected.not_to contain_service('jmxtrans') }
        end

        context 'jmxtrans class with service name' do
          let(:params) {{
            :service_name => 'jmxtrans',
          }}

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('jmxtrans::install') }
          it { is_expected.to contain_class('jmxtrans::service').that_subscribes_to('jmxtrans::install') }

          it { is_expected.not_to contain_package('jmxtrans') }
          it { is_expected.to contain_service('jmxtrans') }
        end

        context 'jmxtrans class with package and service name' do
          let(:params) {{
            :package_name => 'jmxtrans',
            :service_name => 'jmxtrans',
          }}

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('jmxtrans::install') }
          it { is_expected.to contain_class('jmxtrans::service').that_subscribes_to('jmxtrans::install') }

          it { is_expected.to contain_package('jmxtrans').with_ensure('present') }
          it { is_expected.to contain_service('jmxtrans') }
        end

        context 'jmxtrans class with package provider' do
          let(:params) {{
            :package_name => 'jmxtrans',
            :service_name => 'jmxtrans',
            :package_provider => 'gem'
          }}

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('jmxtrans::install') }
          it { is_expected.to contain_class('jmxtrans::service').that_subscribes_to('jmxtrans::install') }

          it do
            is_expected.to contain_package('jmxtrans').with({
              'ensure' => 'present',
              'provider' => 'gem',
            })
          end
          it { is_expected.to contain_service('jmxtrans') }
        end

        context 'jmxtrans class with package source' do
          let(:params) {{
            :package_name => 'jmxtrans',
            :service_name => 'jmxtrans',
            :package_source => 'foo'
          }}

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('jmxtrans::install') }
          it { is_expected.to contain_class('jmxtrans::service').that_subscribes_to('jmxtrans::install') }

          case facts[:osfamily]
          when 'Debian'
            it do
              is_expected.to contain_package('jmxtrans').with({
                'ensure' => 'present',
                'source' => 'foo',
                'provider' => 'dpkg',
              })
            end
            it { is_expected.to contain_service('jmxtrans') }
          when 'RedHat'
            it do
              is_expected.to contain_package('jmxtrans').with({
                'ensure' => 'present',
                'source' => 'foo',
                'provider' => 'rpm',
              })
            end
            it { is_expected.to contain_service('jmxtrans') }
          end
        end
      end
    end
  end
end
