require 'spec_helper'

describe 'jmxtrans' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "jmxtrans class without any parameters" do
          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('jmxtrans::params') }
          it { is_expected.to contain_class('jmxtrans::install').that_comes_before('jmxtrans::config') }
          it { is_expected.to contain_class('jmxtrans::config') }
          it { is_expected.to contain_class('jmxtrans::service').that_subscribes_to('jmxtrans::config') }

          it { is_expected.to contain_service('jmxtrans') }
          it { is_expected.to contain_package('jmxtrans').with_ensure('present') }
        end
      end
    end
  end

  context 'unsupported operating system' do
    describe 'jmxtrans class without any parameters on Solaris/Nexenta' do
      let(:facts) do
        {
          :osfamily        => 'Solaris',
          :operatingsystem => 'Nexenta',
        }
      end

      it { expect { is_expected.to contain_package('jmxtrans') }.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end
end
