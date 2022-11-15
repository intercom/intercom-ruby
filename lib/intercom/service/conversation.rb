# frozen_string_literal: true

require 'intercom/service/base_service'
require 'intercom/api_operations/find_all'
require 'intercom/api_operations/find'
require 'intercom/api_operations/load'
require 'intercom/api_operations/save'
require 'intercom/utils'

module Intercom
  module Service
    class Conversation < BaseService
      include ApiOperations::FindAll
      include ApiOperations::List
      include ApiOperations::Find
      include ApiOperations::Load
      include ApiOperations::Save
      include ApiOperations::Search

      def collection_class
        Intercom::Conversation
      end

      def collection_proxy_class
        Intercom::BaseCollectionProxy
      end

      def mark_read(id)
        @client.put("/conversations/#{id}", read: true)
      end

      def reply(reply_data)
        id = reply_data.delete(:id)
        collection_name = Utils.resource_class_to_collection_name(collection_class)
        response = @client.post("/#{collection_name}/#{id}/reply", reply_data.merge(conversation_id: id))
        collection_class.new.from_response(response)
      end

      def reply_to_last(reply_data)
        collection_name = Utils.resource_class_to_collection_name(collection_class)
        response = @client.post("/#{collection_name}/last/reply", reply_data)
        collection_class.new.from_response(response)
      end

      def open(reply_data)
        reply reply_data.merge(message_type: 'open', type: 'admin')
      end

      def close(reply_data)
        reply reply_data.merge(message_type: 'close', type: 'admin')
      end

      def snooze(reply_data)
        reply_data.fetch(:snoozed_until) { raise 'snoozed_until field is required' }
        reply reply_data.merge(message_type: 'snoozed', type: 'admin')
      end

      def assign(reply_data)
        assignee_id = reply_data.fetch(:assignee_id) { raise 'assignee_id is required' }
        reply reply_data.merge(message_type: 'assignment', assignee_id: assignee_id, type: 'admin')
      end

      def run_assignment_rules(id)
        collection_name = Utils.resource_class_to_collection_name(collection_class)
        response = @client.post("/#{collection_name}/#{id}/run_assignment_rules", {})
        collection_class.new.from_response(response)
      end
    end
  end
end
