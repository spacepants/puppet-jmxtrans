require 'spec_helper'

describe 'jmxtrans' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
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

        context 'jmxtrans class with manage_service_file true' do
          context 'with systemd' do
            let(:facts) {
              {
                :path             => '/usr/local/sbin',
                :service_provider => 'systemd',
              }
            }
            let(:params) {{
              :manage_service_file => true,
            }}

            it { is_expected.to compile.with_all_deps }

            it { is_expected.to contain_file('/etc/systemd/system/jmxtrans.service') }
          end

          context 'without systemd' do
            let(:facts) {
              {
                :path             => '/usr/local/sbin',
                :service_provider => 'initd',
              }
            }

            let(:params) {{
              :manage_service_file => true,
            }}

            it { is_expected.to compile.with_all_deps }

            it { is_expected.to contain_file('/etc/init.d/jmxtrans').with_content(/This file is originally from Java Service Wrapper 3.2.3 distribution/) }
          end
        end

        context 'jmxtrans class with manage_service_file false' do
          context 'with systemd' do
            let(:facts) {
              {
                :path             => '/usr/local/sbin',
                :service_provider => 'systemd',
              }
            }
            let(:params) {{
              :manage_service_file => false,
            }}

            it { is_expected.to compile.with_all_deps }

            it { is_expected.to_not contain_file('/etc/systemd/system/jmxtrans.service') }
          end

          context 'without systemd' do
            let(:facts) {
              {
                :path             => '/usr/local/sbin',
                :service_provider => 'initd',
              }
            }

            let(:params) {{
              :manage_service_file => false,
            }}

            it { is_expected.to compile.with_all_deps }

            it { is_expected.to_not contain_file('/etc/init.d/jmxtrans') }
          end
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
