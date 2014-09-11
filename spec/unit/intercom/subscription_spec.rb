require 'spec_helper'

describe "Intercom::Subscription" do
  it "gets a subscription" do
    Intercom.expects(:get).with("/subscriptions/nsub_123456789", {}).returns(test_subscription)
    subscription = Intercom::Subscription.find(:id => "nsub_123456789")
    subscription.request.topics[0].must_equal "user.created"
    subscription.request.topics[1].must_equal "conversation.user.replied"
  end

  it "creates a subscription" do
    Intercom.expects(:post).with("/subscriptions", {'url' => "http://example.com", 'topics' => ["user.created"]}).returns(test_subscription)
    subscription = Intercom::Subscription.create(:url => "http://example.com", :topics => ["user.created"])
    subscription.request.topics[0].must_equal "user.created"
    subscription.request.url.must_equal "http://example.com"
  end

end