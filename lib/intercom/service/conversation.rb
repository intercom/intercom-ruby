require 'intercom/service/base_service'
require 'intercom/api_operations/find_all'
require 'intercom/api_operations/find'
require 'intercom/api_operations/load'
require 'intercom/api_operations/save'

module Intercom
  module Service
    class Conversation < BaseService
      include ApiOperations::FindAll
      include ApiOperations::Find
      include ApiOperations::Load
      include ApiOperations::Save

      def collection_class
        Intercom::Conversation
      end

      def mark_read(id)
        @client.put("/conversations/#{id}", read: true)
      end

      def reply(reply_data)
        id = reply_data.delete(:id)
        collection_name = Utils.resource_class_to_collection_name(collection_class)
        response = @client.post("/#{collection_name}/#{id}/reply", reply_data.merge(:conversation_id => id))
        collection_class.new.from_response(response)
      end

      def open(reply_data)
        reply reply_data.merge(message_type: 'open', type: 'admin')
      end

      def close(reply_data)
        reply reply_data.merge(message_type: 'close', type: 'admin')
      end

      def assign(reply_data)
        assignee_id = reply_data.fetch(:assignee_id) { fail 'assignee_id is required' }
        reply reply_data.merge(message_type: 'assignment', assignee_id: assignee_id, type: 'admin')
      end
    end
  end
end
