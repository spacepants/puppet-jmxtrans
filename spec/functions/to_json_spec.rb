require 'spec_helper'
require 'json'

describe 'jmxtrans::to_json' do
  it { is_expected.to run.with_params({ 'a' => [1, 2] }).and_return({ 'a' => [1, 2] }.to_json) }
end
