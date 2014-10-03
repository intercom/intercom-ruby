require 'spec_helper'

describe "Intercom::Message" do

  let (:user) {Intercom::User.new("email" => "jim@example.com", :user_id => "12345", :created_at => Time.now, :name => "Jim Bob")}

  it 'creates an user message with symbol keys' do
    Intercom.expects(:post).with('/messages', {'from' => { :type => 'user', :email => 'jim@example.com'}, 'body' => 'halp'}).returns(:status => 200)
    Intercom::Message.create(:from => { :type => "user", :email => "jim@example.com" }, :body => "halp")
  end
  
  it "creates an user message with string keys" do
    Intercom.expects(:post).with('/messages', {'from' => { 'type' => 'user', 'email' => 'jim@example.com'}, 'body' => 'halp'}).returns(:status => 200)
    Intercom::Message.create('from' => { 'type' => "user", 'email' => "jim@example.com" }, 'body' => "halp")
  end
  
  it "creates a admin message" do
    Intercom.expects(:post).with('/messages', {'from' => { 'type' => "admin", 'id' => "1234" }, 'to' => { 'type' => 'user', 'id' => '5678' }, 'body' => 'halp', 'message_type' => 'inapp'}).returns(:status => 200)
    Intercom::Message.create('from' => { 'type' => "admin", 'id' => "1234" }, :to => { 'type' => 'user', 'id' => '5678' }, 'body' => "halp", 'message_type' => 'inapp')
  end
end
