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
      replace_with 'expect({{arguments.last}}).to match({{arguments.first}})'
    end
  end

  within_files '**/spec/**/*.rb' do
    with_node node_type: 'send', message: 'assert_no_match', arguments: { size: 2 }  do
      replace_with 'expect({{arguments.last}}).not_to match({{arguments.first}})'
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

  # has_entries => hash_including
  within_files '**/spec/**/*.rb' do
    with_node  node_type: 'send', message: 'has_entries' do
      replace_with "hash_including({{arguments}})"
    end
  end

  # @subscription_handler.expect(
  #          :new,
  #          @subscription_handler,
  #          [
  #            @new_org,
  #            :add,
  #            @invited_by,
  #            @invitee,
  #          ]
  #        )
  #  =>
  # allow(@subscription_handler).to receive(:new).with(**[
   #   @new_org,
   #   :add,
   #   @invited_by,
   #   @invitee,
   # ]).and_return(@subscription_handler)
  within_files '**/spec/**/*.rb' do
    with_node node_type: 'send', message: 'expect', arguments: {size: 3}  do
      replace_with "allow({{receiver}}).to receive({{arguments.first}}).with(*{{arguments.last}}).and_return({{arguments.second}})"
    end
  end

  # @sub_handler_mock.expect(
  #         :update_subscription_if_required,
  #         true,
  #       )
  # =>
  # allow(@sub_handler_mock).to receive(:update_subscription_if_required).and_return(true)
  within_files '**/spec/**/*.rb' do
    with_node node_type: 'send', message: 'expect', arguments: {size: 2}  do
      replace_with "allow({{receiver}}).to receive({{arguments.first}}).and_return({{arguments.last}})"
    end
  end

  #  DeliveryMethods::SlackMessage.any_instance.stubs(:deliver).returns(:x) =>  allow_any_instance_of(DeliveryMethods::SlackMessage).to receive(:deliver).and_return(:x)
  within_files '**/spec/**/*.rb' do
    with_node node_type: 'send', message: 'returns', receiver: { node_type: 'send', message: 'stubs', arguments: {size: 1}, receiver: {node_type: 'send', message: 'any_instance'}}  do
      replace_with "allow_any_instance_of({{receiver.receiver.receiver}}).to receive({{receiver.arguments}}).and_return({{arguments}})"
    end
  end

  # Outcome.any_instance.stubs(:destroy!).raises(StandardError) => allow_any_instance_of(Outcome).to receive(:destroy!).and_raise(StandardError)
  within_files '**/spec/**/*.rb' do
    with_node node_type: 'send', message: 'raises', receiver: { node_type: 'send', message: 'stubs', arguments: {size: 1}, receiver: {node_type: 'send', message: 'any_instance'}}  do
      replace_with "allow_any_instance_of({{receiver.receiver.receiver}}).to receive({{receiver.arguments}}).and_raise({{arguments}})"
    end
  end

  #  DeliveryMethods::SlackMessage.any_instance.stubs(:deliver) =>  allow_any_instance_of(DeliveryMethods::SlackMessage).to receive(:deliver)
  within_files '**/spec/**/*.rb' do
    with_node  node_type: 'send', message: 'stubs', arguments: {size: 1}, receiver: {node_type: 'send', message: 'any_instance'}  do
      replace_with "allow_any_instance_of({{receiver.receiver}}).to receive({{arguments}})"
    end
  end

  # Audited::Audit.stubs(:create!).raises(StandardError) => allow(Audited::Audit).to receive(:create!).and_raise(StandardError)
  within_files '**/spec/**/*.rb' do
    with_node node_type: 'send', message: 'raises', receiver: { node_type: 'send', message: 'stubs', arguments: {size: 1}}  do
      replace_with "allow({{receiver.receiver}}).to receive({{receiver.arguments}}).and_raise({{arguments}})"
    end
  end

  # .stubs(foo).with(x).returns(bar) => receive(foo).with(x).and_return(bar)
  within_files '**/spec/**/*.rb' do
    with_node node_type: 'send', message: 'returns', receiver: { node_type: 'send', message: 'with', receiver: {node_type: 'send', message: 'stubs'}} do
      replace_with "allow({{receiver.receiver.receiver}}).to receive({{receiver.receiver.arguments}}).with({{receiver.arguments}}).and_return({{arguments}})"
    end
  end

  # .stubs(foo).returns(bar) => receive(foo).and_return(bar)
  within_files '**/spec/**/*.rb' do
   with_node node_type: 'send', message: 'returns', receiver: {node_type: 'send', message: 'stubs'} do
      replace_with "allow({{receiver.receiver}}).to receive({{receiver.arguments}}).and_return({{arguments}})"
    end
  end

  # .stubs(:foo) => allow().to receive(:foo)
  within_files '**/spec/**/*.rb' do
    with_node  node_type: 'send', message: 'stubs', arguments: {size: 1} do
      replace_with "allow({{receiver}}).to receive({{arguments}})"
    end
  end

  # .stubs => receive_messages
  within_files '**/spec/**/*.rb' do
    with_node  node_type: 'send', message: 'stubs' do
      replace_with "allow({{receiver}}).to receive_messages({{arguments}})"
    end
  end

  # assert_raise(exception) do block end => expect do block end.to raise_error(exception)
  within_files '**/spec/**/*.rb' do
    with_node  node_type: 'block', caller: { node_type: 'send', message: 'assert_raise', arguments: { size: 1 }}  do
      replace_with "expect do \n{{body}} \nend.to raise_error({{caller.arguments.first}})"
    end
  end


  # user.stubs(:invited?).returns(true) => allow(user).to receive(:invited?).and_return(true)
  within_files '**/spec/**/*.rb' do
    with_node  node_type: 'send', receiver: { node_type: 'send', message: 'stubs', arguments: { size: 1 }}, message: "returns", arguments: { size: 1}  do
      replace_with "allow({{receiver.receiver}}).to receive({{receiver.arguments.first}}).and_return({{arguments.first}})"
    end
  end


  #  DeliveryMethods::SlackMessage.any_instance.expects(:deliver) => expect_any_instance_of(DeliveryMethods::SlackMessage).to receive(:deliver)
  within_files '**/spec/**/*.rb' do
    with_node  node_type: 'send', message: 'expects', arguments: { size: 1 }, receiver: { node_type: 'send', message: 'any_instance' }  do
      replace_with "expect_any_instance_of({{receiver.receiver}}).to receive({{arguments.first}})"
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

  # assert_not_equal false, false => expect(false).not_to eq(false)
  within_files '**/spec/**/*.rb' do
    with_node node_type: 'send', message: 'assert_not_equal', arguments: { size: 2 }  do
      replace_with 'expect({{arguments.first}}).not_to eq({{arguments.last}})'
    end
  end

  # SlackFormatters::WinCreated.any_instance.expects(:call).with(
  #     recipient: @user,
  #     win: @win,
  #     winner: @user
  #   ).returns({ format: "some_format" })
  # =>
  # expect_any_instance_of(SlackFormatters::WinCreated).to receive(:call).with(recipient: @user,
  #     win: @win,
  #     winner: @user).and_return({ format: "some_format" })
  within_files '**/spec/**/*.rb' do
    with_node  node_type: 'send', receiver: { node_type: 'send', message: 'with', receiver: { node_type: 'send', message: 'expects', arguments: { size: 1 },  receiver: { node_type: 'send', message: 'any_instance' } }}, message: "returns", arguments: { size: 1}  do
      replace_with "expect_any_instance_of({{receiver.receiver.receiver.receiver}}).to receive({{receiver.receiver.arguments.first}}).with({{receiver.arguments}}).and_return({{arguments.first}})"
    end
  end


  # FeatureGate::AccessWins.any_instance.expects(:call).returns(@result_mock) => expect_any_instance_of(FeatureGate::AccessWins).to receive(:call).and_return(@result_mock)
  within_files '**/spec/**/*.rb' do
    with_node  node_type: 'send', receiver: { node_type: 'send', message: 'expects', arguments: { size: 1 }, receiver: { node_type: 'send', message: 'any_instance' }}, message: "returns", arguments: { size: 1}  do
      replace_with "expect_any_instance_of({{receiver.receiver.receiver}}).to receive({{receiver.arguments.first}}).and_return({{arguments.first}})"
    end
  end

  # @data_loader_class.expects(:new).with(user: @user).returns(@data_loader) => expect(@data_loader_class).to receive(user: @user).with(:new).at_least(:once).and_return(@data_loader)
  within_files '**/spec/**/*.rb' do
    with_node({
      node_type: 'send',
      receiver: {
        node_type: 'send',
        message: 'with',
        # arguments: { size: 1 },
        receiver: {
          node_type: 'send',
          message: 'expects',
          arguments: {size: 1}
        }
      },
      message: 'returns',
      arguments: {size: 1}
    }
    )  do
        replace_with 'expect({{receiver.receiver.receiver}}).to receive({{receiver.receiver.arguments.first}}).with({{receiver.arguments}}).at_least(:once).and_return({{arguments.first}})'
      end
  end


  # ProcessSkillGeneratorJob.expects(:perform_later).with(generator) => expect(ProcessSkillGeneratorJob).to receive(:perform_later).with(generator).at_least(:once)
  within_files '**/spec/**/*.rb' do
    with_node node_type: 'send', receiver: { node_type: 'send', message: 'expects', arguments: { size: 1 }}, message: 'with'  do
      replace_with 'expect({{receiver.receiver}}).to receive({{receiver.arguments.first}}).with({{arguments.first}}).at_least(:once)'
    end
  end

  # reporter.expects(:has_active_subscription?).returns(false) => expect(reporter).to receive(:has_active_subscription?).and_return(false)
  within_files '**/spec/**/*.rb' do
    with_node  node_type: 'send', receiver: { node_type: 'send', message: 'expects', arguments: { size: 1 }}, message: "returns", arguments: { size: 1}  do
      replace_with "expect({{receiver.receiver}}).to receive({{receiver.arguments.first}}).and_return({{arguments.first}})"
    end
  end

  # reporter.expects(:has_active_subscription?).returns(false) => expect(reporter).to receive(:has_active_subscription?).and_return(false)
  within_files '**/spec/**/*.rb' do
    with_node  node_type: 'send', receiver: { node_type: 'send', message: 'expects', arguments: { size: 1 }}, message: "returns", arguments: { size: 1}  do
      replace_with "expect({{receiver.receiver}}).to receive({{receiver.arguments.first}}).and_return({{arguments.first}})"
    end
  end

  # @svc.expects(:call!).raises(@error_mock) => expect(@svc).to receive(:call!).and_raise(@error_mock)
  within_files '**/spec/**/*.rb' do
    with_node node_type: 'send', message: 'raises', receiver: {node_type: 'send', message: 'expects', arguments: {size: 1}} do
      replace_with "expect({{receiver.receiver}}).to receive({{receiver.arguments}}).and_raise({{arguments}})"
    end
  end

  # @tracker.expects(:track) => expect(@tracker).to receive(:track).at_least(:once)
  within_files '**/spec/**/*.rb' do
    with_node node_type: 'send', message: 'expects', arguments: {size: 1} do
      replace_with "expect({{receiver}}).to receive({{arguments}}).at_least(:once)"
    end
  end

  # stub => double
  within_files '**/spec/**/*.rb' do
   with_node node_type: 'send', message: 'stub', arguments: {size: 0} do
      replace_with "double"
    end
  end

  # returns => and_return
  within_files '**/spec/**/*.rb' do
    with_node node_type: 'send', message: 'returns'  do
      replace_with "{{receiver}}.and_return({{arguments}})"
    end
  end

  # foo.with(nil).returns => foo.returns
  within_files '**/spec/**/*.rb' do
    with_node node_type: 'send', message: 'with', arguments: {first: nil, size: 1}  do
      replace_with "{{receiver}}"
    end
  end
end

