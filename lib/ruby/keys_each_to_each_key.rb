# frozen_string_literal: true

Synvert::Rewriter.new 'ruby', 'keys_each_to_each_key' do
  description <<~EOS
    It convert `Hash#keys.each` to `Hash#each_key`

    ```ruby
    params.keys.each {}
    ```

    =>

    ```ruby
    params.each_key {}
    ```
  EOS

  within_files Synvert::ALL_RUBY_FILES do
    # params.keys.each {}
    # =>
    # params.each_key {}
    find_node '.send[receiver=.send[message=keys][arguments.size=0]][message=each][arguments.size=0]' do
      replace :receiver, with: '{{receiver.receiver}}'
      replace :message, with: 'each_key'
    end
  end
end
