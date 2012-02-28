require "spec_helper"

describe "/v1/impressions" do
  it "creates a good impression" do
    Intercom.expects(:post).with("impressions", {"email" => "jo@example.com", "location" => "/some/path/in/my/app"}).returns({"unread_messages" => 10})
    impression = Intercom::Impression.create("email" => "jo@example.com", "location" => "/some/path/in/my/app")
    impression.unread_messages.must_equal 10
  end
end