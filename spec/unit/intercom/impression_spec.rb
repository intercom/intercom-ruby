require "spec_helper"

describe "/v1/impressions" do
  it "creates a good impression" do
    Intercom.expects(:post).with("/v1/users/impressions", {"email" => "jo@example.com", "location" => "/some/path/in/my/app"}).returns({"unread_messages" => 10})
    impression = Intercom::Impression.create("email" => "jo@example.com", "location" => "/some/path/in/my/app")
    impression.unread_messages.must_equal 10
  end

  it "sets/gets allowed keys" do
    params = {"user_ip" => "1.2.3.4", "user_agent" => "ie6", "location" => "/some/path/in/my/app", "email" => "me@example.com", :user_id => "abc123"}
    impression = Intercom::Impression.new(params)
    impression.to_hash.keys.sort.must_equal params.keys.map(&:to_s).sort
    params.keys.each do | key|
      impression.send(key).must_equal params[key]
    end
  end
end