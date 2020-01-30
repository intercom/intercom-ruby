require 'spec_helper'

describe "Intercom::Conversation" do
  let(:client) { Intercom::Client.new(token: 'token') }

  it "gets a conversation" do
    client.expects(:get).with("/conversations/147", {}).returns(test_conversation)
    client.conversations.find(:id => "147")
  end

  it "gets all conversations" do
    client.expects(:get).with("/conversations", {}).returns(test_conversation_list)
    client.conversations.all.each { |c| }
  end

  it 'marks a conversation as read' do
    client.expects(:put).with('/conversations/147', { read: true })
    client.conversations.mark_read('147')
  end

  it 'replies to a conversation' do
    client.expects(:post).with('/conversations/147/reply', { type: 'user', body: 'Thanks again', message_type: 'comment', user_id: 'ac4', conversation_id: '147' }).returns(test_conversation)
    client.conversations.reply(id: '147', type: 'user', body: 'Thanks again', message_type: 'comment', user_id: 'ac4')
  end

  it 'replies to a conversation with an attachment' do
    client.expects(:post).with('/conversations/147/reply', { type: 'user', body: 'Thanks again', message_type: 'comment', user_id: 'ac4', conversation_id: '147', attachment_urls: ["http://www.example.com/attachment.jpg"] }).returns(test_conversation)
    client.conversations.reply(id: '147', type: 'user', body: 'Thanks again', message_type: 'comment', user_id: 'ac4', attachment_urls: ["http://www.example.com/attachment.jpg"])
  end

  it 'sends a reply to a users last conversation from an admin' do
    client.expects(:post).with('/conversations/last/reply', { type: 'admin', body: 'Thanks again', message_type: 'comment', user_id: 'ac4', admin_id: '123' }).returns(test_conversation)
    client.conversations.reply_to_last(type: 'admin', body: 'Thanks again', message_type: 'comment', user_id: 'ac4', admin_id: '123')
  end

  it 'opens a conversation' do
    client.expects(:post).with('/conversations/147/reply', { type: 'admin', message_type: 'open', conversation_id: '147', admin_id: '123'}).returns(test_conversation)
    client.conversations.open(id: '147', admin_id: '123')
  end

  it 'closes a conversation' do
    client.expects(:post).with('/conversations/147/reply', { type: 'admin', message_type: 'close', conversation_id: '147', admin_id: '123'}).returns(test_conversation)
    client.conversations.close(id: '147', admin_id: '123')
  end

  it 'assigns a conversation' do
    client.expects(:post).with('/conversations/147/reply', { type: 'admin', message_type: 'assignment', conversation_id: '147', admin_id: '123', assignee_id: '124'}).returns(test_conversation)
    client.conversations.assign(id: '147', admin_id: '123', assignee_id: '124')
  end

  it 'snoozes a conversation' do
    client.expects(:post).with('/conversations/147/reply', { type: 'admin', message_type: 'snoozed', conversation_id: '147', admin_id: '123', snoozed_until: tomorrow}).returns(test_conversation)
    client.conversations.snooze(id: '147', admin_id: '123', snoozed_until: tomorrow)
  end

  it 'runs assignment rules on a conversation' do
    client.expects(:post).with('/conversations/147/run_assignment_rules').returns(test_conversation)
    client.conversations.run_assignment_rules('147')
  end

  describe 'nested resources' do
    let(:conversation) { Intercom::Conversation.new('id' => '1', 'client' => client) }
    let(:tag) { Intercom::Tag.new('id' => '1') }

    it 'adds a tag to a conversation' do
      client.expects(:post).with("/conversations/1/tags", { 'id': tag.id, 'admin_id': test_admin['id'] }).returns(tag.to_hash)
      conversation.add_tag({ "id": tag.id,  "admin_id": test_admin['id'] })
    end

    it 'does not add a tag to a conversation if no admin_id is passed' do
      client.expects(:post).with("/conversations/1/tags", { 'id': tag.id }).returns(nil)
      _(proc { conversation.add_tag({ "id": tag.id }) }).must_raise Intercom::HttpError
    end

    it 'removes a tag from a conversation' do
      client.expects(:delete).with("/conversations/1/tags/1", { "id": tag.id, "admin_id": test_admin['id'] }).returns(tag.to_hash)
      conversation.remove_tag({ "id": tag.id, "admin_id": test_admin['id'] })
    end

    it 'does not remove a tag from a conversation if no admin_id is passed' do
      client.expects(:delete).with("/conversations/1/tags/1", { "id": tag.id }).returns(nil)
      _(proc { conversation.remove_tag({ "id": tag.id }) }).must_raise Intercom::HttpError
    end
  end
end
