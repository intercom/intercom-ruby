require 'spec_helper'

describe "Intercom::Notification" do

  it "converts notification hash to object" do
    payload = Intercom::Notification.new(test_user_notification)
    payload.must_be_instance_of Intercom::Notification
  end

  it "returns correct model type for User" do
    payload = Intercom::Notification.new(test_user_notification)
    payload.model_type.must_equal Intercom::User
  end

  it "returns correct User notification topic" do
    payload = Intercom::Notification.new(test_user_notification)
    payload.topic.must_equal "user.created"
  end

  it "returns instance of User" do
    payload = Intercom::Notification.new(test_user_notification)
    payload.model.must_be_instance_of Intercom::User
  end

  it "returns instance of Conversation" do
    payload = Intercom::Notification.new(test_conversation_notification)
    payload.model.must_be_instance_of Intercom::Conversation
  end

  it "returns correct model type for Conversation" do
    payload = Intercom::Notification.new(test_conversation_notification)
    payload.model_type.must_equal Intercom::Conversation
  end

  it "returns correct Conversation notification topic" do
    payload = Intercom::Notification.new(test_conversation_notification)
    payload.topic.must_equal "conversation.user.created"
  end

  it "returns inner User object for Conversation" do
    payload = Intercom::Notification.new(test_conversation_notification)
    payload.model.user.must_be_instance_of Intercom::User
  end

end