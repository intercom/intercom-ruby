require 'spec_helper'

describe "Intercom::Conversation" do
  let (:client) { Intercom::Client.new(app_id: 'app_id',  api_key: 'api_key') }

  it "gets a conversation" do
    client.expects(:get).with("/conversations/147", {}).returns(test_conversation)
    client.conversations.find(:id => "147")
  end

  it 'marks a conversation as read' do
    client.expects(:put).with('/conversations/147', { read: true })
    client.conversations.mark_read('147')
  end

  it 'replies to a conversation' do
    client.expects(:post).with('/conversations/147/reply', { type: 'user', body: 'Thanks again', message_type: 'comment', user_id: 'ac4', conversation_id: '147' }).returns(test_conversation)
    client.conversations.reply(id: '147', type: 'user', body: 'Thanks again', message_type: 'comment', user_id: 'ac4')
  end

  # it "creates a subscription" do
  #   client.expects(:post).with("/subscriptions", {'url' => "http://example.com", 'topics' => ["user.created"]}).returns(test_subscription)
  #   subscription = client.subscriptions.create(:url => "http://example.com", :topics => ["user.created"])
  #   subscription.request.topics[0].must_equal "user.created"
  #   subscription.request.url.must_equal "http://example.com"
  # end

end
