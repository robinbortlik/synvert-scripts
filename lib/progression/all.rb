Synvert::Rewriter.new 'progression', 'all' do
  within_files '**/spec/**/*.rb' do
    with_node node_type: 'send', message: 'assert_equal', arguments: { size: 2 }  do
      replace_with 'expect({{arguments.first}}).to eq({{arguments.last}})'
    end
  end

  within_files '**/spec/**/*.rb' do
    with_node node_type: 'send', message: 'assert', arguments: { size: 1 }  do
      replace_with 'expect({{arguments.first}}).to be_truthy'
    end
  end

  within_files '**/spec/**/*.rb' do
    with_node node_type: 'send', message: 'assert_nil', arguments: { size: 1 }  do
      replace_with 'expect({{arguments.first}}).to be_nil'
    end
  end

  within_files '**/spec/**/*.rb' do
    with_node node_type: 'send', message: 'refute', arguments: { size: 1 }  do
      replace_with 'expect({{arguments.first}}).to be_falsey'
    end
  end

  within_files '**/spec/**/*.rb' do
    with_node node_type: 'send', message: 'refute_equal', arguments: { size: 2 }  do
      replace_with 'expect({{arguments.first}}).not_to eq({{arguments.last}})'
    end
  end

  within_files '**/spec/**/*.rb' do
    with_node node_type: 'send', message: 'mock'  do
      replace_with 'double'
    end
  end

  # assert_raise(exception) do block end => expect do block end.to raise_error(exception)
  within_files '**/spec/**/*.rb' do
    with_node  node_type: 'block', caller: { node_type: 'send', message: 'assert_raise', arguments: { size: 1 }}  do
      replace_with "expect do \n{{body}} \nend.to raise_error({{caller.arguments.first}})"
    end
  end
end
