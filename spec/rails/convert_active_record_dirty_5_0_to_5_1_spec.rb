# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Convert ActiveRecord::Dirty 5.0 to 5.1' do
  let(:rewriter_name) { 'rails/convert_active_record_dirty_5_0_to_5_1' }

  before do
    FakeFS() do
      FileUtils.mkdir('db')
    end
  end

  context 'model' do
    let(:fake_file_path) { 'app/models/post.rb' }

    let(:test_content) { <<~EOS }
      class Post < ActiveRecord::Base
        before_create :call_before_create
        before_update :call_before_update, unless: :title_changed?
        before_save :call_before_save, if: -> { status_changed? || summary_changed? }
        after_create :call_after_create
        after_update :call_after_update, unless: :title_changed?
        after_save :call_after_save, if: :call_change?
        after_update :change_user, if: :user_changed?
        after_commit :publish_user_change

        before_save do
          if title_changed?
          end
        end

        def call_before_create
          if title_changed? && user_changed?
            changes
          end
        end

        def call_after_create
          if title_changed? && user_changed?
            changes
          end
        end

        def user_changed?
        end

        def change_user
        end

        def call_change?
          status_changed? || summary_changed?
        end
      end
    EOS

    let(:test_rewritten_content) { <<~EOS }
      class Post < ActiveRecord::Base
        before_create :call_before_create
        before_update :call_before_update, unless: :will_save_change_to_title?
        before_save :call_before_save, if: -> { will_save_change_to_status? || will_save_change_to_summary? }
        after_create :call_after_create
        after_update :call_after_update, unless: :saved_change_to_title?
        after_save :call_after_save, if: :call_change?
        after_update :change_user, if: :user_changed?
        after_commit :publish_user_change

        before_save do
          if will_save_change_to_title?
          end
        end

        def call_before_create
          if will_save_change_to_title? && user_changed?
            changes_to_save
          end
        end

        def call_after_create
          if saved_change_to_title? && user_changed?
            saved_changes
          end
        end

        def user_changed?
        end

        def change_user
        end

        def call_change?
          saved_change_to_status? || saved_change_to_summary?
        end
      end
    EOS

    include_examples 'convertable'
  end

  context 'observer' do
    let(:fake_file_path) { 'app/observers/post_observer.rb' }

    let(:test_content) { <<~EOS }
      class PostObserver < ActiveRecord::Observer
        def after_update
          if title_changed?
            changes
          end
          next_call
        end

        def next_call
          changes
        end
      end
    EOS

    let(:test_rewritten_content) { <<~EOS }
      class PostObserver < ActiveRecord::Observer
        def after_update
          if saved_change_to_title?
            saved_changes
          end
          next_call
        end

        def next_call
          saved_changes
        end
      end
    EOS

    include_examples 'convertable'
  end

  context 'dirty api in method call' do
    let(:fake_file_path) { 'app/models/post.rb' }

    let(:test_content) { <<~EOS }
      class Conference < ApplicationRecord
        before_update :update_talk_time

        private

        def update_talk_time
          return if skip_recalculation?

          self.talk_time = adjusted_talk_time
        end

        def skip_recalculation?
          return true if talk_ended.nil?
          return true if talk_started.nil?
          return true unless talk_ended_changed? || talk_started_changed?

          false
        end
      end
    EOS

    let(:test_rewritten_content) { <<~EOS }
      class Conference < ApplicationRecord
        before_update :update_talk_time

        private

        def update_talk_time
          return if skip_recalculation?

          self.talk_time = adjusted_talk_time
        end

        def skip_recalculation?
          return true if talk_ended.nil?
          return true if talk_started.nil?
          return true unless will_save_change_to_talk_ended? || will_save_change_to_talk_started?

          false
        end
      end
    EOS

    include_examples 'convertable'
  end
end
