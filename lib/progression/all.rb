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

  # assert_match(/progression/, team.slug) => expect(/progression/).to match(team.slug)
  within_files '**/spec/**/*.rb' do
    with_node node_type: 'send', message: 'assert_match', arguments: { size: 2 }  do
      replace_with 'expect({{arguments.first}}).to match({{arguments.last}})'
    end
  end

  # assert_not false => expect(false).to be_falsey
  within_files '**/spec/**/*.rb' do
    with_node node_type: 'send', message: 'assert_not', arguments: { size: 1 }  do
      replace_with 'expect({{arguments.first}}).to be_falsey'
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

  # reporter.expects(:has_active_subscription?).returns(false) => expect(reporter).to receive(:has_active_subscription?).and_return(false)
  within_files '**/spec/**/*.rb' do
    with_node  node_type: 'send', receiver: { node_type: 'send', message: 'expects', arguments: { size: 1 }}, message: "returns", arguments: { size: 1}  do
      replace_with "expect({{receiver.receiver}}).to receive({{receiver.arguments.first}}).and_return({{arguments.first}})"
    end
  end

  # user.stubs(:invited?).returns(true) => allow(user).to receive(:invited?).and_return(true)
  within_files '**/spec/**/*.rb' do
    with_node  node_type: 'send', receiver: { node_type: 'send', message: 'stubs', arguments: { size: 1 }}, message: "returns", arguments: { size: 1}  do
      replace_with "allow({{receiver.receiver}}).to receive({{receiver.arguments.first}}).and_return({{arguments.first}})"
    end
  end

  # user.expects(:set_time_zone).at_least_once => expect(user).to receive(:set_time_zone).at_least(:once)
  within_files '**/spec/**/*.rb' do
    with_node  node_type: 'send', receiver: { node_type: 'send', message: 'expects', arguments: { size: 1 }}, message: "at_least_once", arguments: { size: 0}  do
      replace_with "expect({{receiver.receiver}}).to receive({{receiver.arguments.first}}).at_least(:once)"
    end
  end

  # user.expects(:set_time_zone).never => expect(user).not_to receive(:set_time_zone)
  within_files '**/spec/**/*.rb' do
   with_node  node_type: 'send', receiver: { node_type: 'send', message: 'expects', arguments: { size: 1 }}, message: "never", arguments: { size: 0}  do
      replace_with "expect({{receiver.receiver}}).not_to receive({{receiver.arguments.first}})"
    end
  end

  # user.expects(:set_time_zone).once => expect(user).to receive(:set_time_zone).once
  within_files '**/spec/**/*.rb' do
   with_node  node_type: 'send', receiver: { node_type: 'send', message: 'expects', arguments: { size: 1 }}, message: "once", arguments: { size: 0}  do
      replace_with "expect({{receiver.receiver}}).to receive({{receiver.arguments.first}}).once"
    end
  end

  # .at_least_once => at_least(:once)
  within_files '**/spec/**/*.rb' do
    with_node node_type: 'send', message: 'at_least_once'  do
      replace_with '{{receiver}}.at_least(:once)'
    end
  end
end
