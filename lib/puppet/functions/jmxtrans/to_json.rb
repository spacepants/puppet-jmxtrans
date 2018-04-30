Puppet::Functions.create_function(:'jmxtrans::to_json') do
  dispatch :data_to_json do
    param 'Data', :data
    optional_param 'Boolean', :pretty
  end

  def data_to_json(data, pretty = false)
    require 'json'

    if pretty
      JSON.pretty_generate(data)
    else
      data.to_json
    end
  end
end
