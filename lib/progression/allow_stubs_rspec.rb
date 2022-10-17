Synvert::Rewriter.new 'progression', 'allow_stubs_rspec' do
  within_files '**/*.rb' do
    with_node node_type: 'send', receiver: { node_type: 'send', message: 'stubs', arguments: { size: 1 } }, message: 'returns', arguments: { size: 1 } do
      replace_with 'allow({{receiver}}).to receive({{arguments.first}}).and_return({{arguments.last}})'
    end
  end
end
