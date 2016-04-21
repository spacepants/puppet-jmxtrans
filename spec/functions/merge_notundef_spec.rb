require 'spec_helper'

describe 'jmxtrans::merge_notundef' do
  it { is_expected.to run.with_params({ 'a' => 1 }, { 'b' => 2 }).and_return({ 'a' => 1, 'b' => 2}) }
end
