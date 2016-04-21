Puppet::Functions.create_function(:'jmxtrans::to_json') do
  dispatch :data_to_json do
    param 'Data', :data
  end

  def data_to_json(data)
    require 'json'

    data.to_json
  end
end
