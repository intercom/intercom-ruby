require "spec_helper"

describe Intercom::SearchCollectionProxy do
  let(:client) { Intercom::Client.new(token: 'token') }

  it "sends query to the contact search endpoint" do
    client.expects(:post).with("/contacts/search", { query: {} }).returns(page_of_contacts(false))
    client.contacts.search(query: {}).first
  end

  it "sends query to the conversation search endpoint" do
    client.expects(:post).with("/conversations/search", { query: {} }).returns(test_conversation_list)
    client.conversations.search(query: {}).first
  end

  it "sends query to the contact search endpoint with sort_field" do
    client.expects(:post).with("/contacts/search", { query: {}, sort: { field: "name" } }).returns(page_of_contacts(false))
    client.contacts.search(query: {}, sort_field: "name").first
  end

  it "sends query to the contact search endpoint with sort_field and sort_order" do
    client.expects(:post).with("/contacts/search", { query: {}, sort: { field: "name", order: "ascending" } }).returns(page_of_contacts(false))
    client.contacts.search(query: {}, sort_field: "name", sort_order: "ascending").first
  end

  it "sends query to the contact search endpoint with per_page" do
    client.expects(:post).with("/contacts/search", { query: {}, pagination: { per_page: 10 }}).returns(page_of_contacts(false))
    client.contacts.search(query: {}, per_page: 10).first
  end

  it "sends query to the contact search endpoint with starting_after" do
    client.expects(:post).with("/contacts/search", { query: {}, pagination: { starting_after: "EnCrYpTeDsTrInG" }}).returns(page_of_contacts(false))
    client.contacts.search(query: {}, starting_after: "EnCrYpTeDsTrInG").first
  end

  it "stops iterating if no starting_after value" do
    client.expects(:post).with("/contacts/search", { query: {} }).returns(page_of_contacts(false))
    emails = []
    client.contacts.search(query: {}).each { |contact| emails << contact.email }
    _(emails).must_equal %w[test1@example.com test2@example.com test3@example.com]
  end

  it "keeps iterating if starting_after value" do
    client.expects(:post).with("/contacts/search", { query: {} }).returns(page_of_contacts(true))
    client.expects(:post).with("/contacts/search", { query: {}, pagination: { starting_after: "EnCrYpTeDsTrInG" }}).returns(page_of_contacts(false))
    emails = []
    client.contacts.search(query: {}).each { |contact| emails << contact.email }
  end

  it "supports indexed array access" do
    client.expects(:post).with("/contacts/search", { query: {} }).returns(page_of_contacts(false))
    _(client.contacts.search(query: {})[0].email).must_equal 'test1@example.com'
  end

  it "supports map" do
    client.expects(:post).with("/contacts/search", { query: {} }).returns(page_of_contacts(false))
    emails = client.contacts.search(query: {}).map { |contact| contact.email }
    _(emails).must_equal %w[test1@example.com test2@example.com test3@example.com]
  end
end
