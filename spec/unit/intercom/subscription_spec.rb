require 'spec_helper'

describe "Intercom::Subscription" do
  let(:client) { Intercom::Client.new(token: 'token') }

  it "gets a subscription" do
    client.expects(:get).with("/subscriptions/nsub_123456789", {}).returns(test_subscription)
    subscription = client.subscriptions.find(:id => "nsub_123456789")
    _(subscription.request.topics[0]).must_equal "user.created"
    _(subscription.request.topics[1]).must_equal "conversation.user.replied"
  end

  it "creates a subscription" do
    client.expects(:post).with("/subscriptions", {'url' => "http://example.com", 'topics' => ["user.created"]}).returns(test_subscription)
    subscription = client.subscriptions.create(:url => "http://example.com", :topics => ["user.created"])
    _(subscription.request.topics[0]).must_equal "user.created"
    _(subscription.request.url).must_equal "http://example.com"
  end
end
