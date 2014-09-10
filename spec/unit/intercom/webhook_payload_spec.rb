require 'spec_helper'

describe "Intercom::Webhook::Payload" do

  it "converts webhook hash to object" do
    payload = Intercom::Webhook::Payload.new(test_webhook_user)
    payload.must_be_instance_of Intercom::Webhook::Payload
  end

  it "returns correct model type for User" do
    payload = Intercom::Webhook::Payload.new(test_webhook_user)
    payload.model_type.must_equal Intercom::User
  end

  it "returns correct notification topic" do
    payload = Intercom::Webhook::Payload.new(test_webhook_user)
    payload.topic.must_equal "user.created"
  end

  it "returns instance of User" do
    payload = Intercom::Webhook::Payload.new(test_webhook_user)
    payload.to_model.must_be_instance_of Intercom::User
  end

  it "returns instance of Conversation" do
    payload = Intercom::Webhook::Payload.new(test_webhook_conversation)
    payload.to_model.must_be_instance_of Intercom::Conversation
  end

  it "returns correct model type for User" do
    payload = Intercom::Webhook::Payload.new(test_webhook_conversation)
    payload.model_type.must_equal Intercom::Conversation
  end

  it "returns correct notification topic" do
    payload = Intercom::Webhook::Payload.new(test_webhook_conversation)
    payload.topic.must_equal "conversation.user.created"
  end

  it "returns inner User object for Conversation" do
    payload = Intercom::Webhook::Payload.new(test_webhook_conversation)
    payload.to_model.user.must_be_instance_of Intercom::User
  end

end