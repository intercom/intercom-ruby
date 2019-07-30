require "spec_helper"

describe Intercom::SearchCollectionProxy do
  let (:client) { Intercom::Client.new(app_id: 'app_id',  api_key: 'api_key') }

  it "send query to the customer search endpoint" do
    client.expects(:post).with("/customers/search", { query: {} }).  returns(page_of_customers(false))
    client.customers.search(query: {}).first
  end

  it "send query to the customer search endpoint with sort_field" do
    client.expects(:post).with("/customers/search", { query: {}, sort: { field: "name" } }).  returns(page_of_customers(false))
    client.customers.search(query: {}, sort_field: "name").first
  end

  it "send query to the customer search endpoint with sort_field and sort_order" do
    client.expects(:post).with("/customers/search", { query: {}, sort: { field: "name", order: "ascending" } }).  returns(page_of_customers(false))
    client.customers.search(query: {}, sort_field: "name", sort_order: "ascending").first
  end

  it "send query to the customer search endpoint with per_page" do
    client.expects(:post).with("/customers/search", { query: {}, pagination: { per_page: 10 }}).  returns(page_of_customers(false))
    client.customers.search(query: {}, per_page: 10).first
  end

  it "send query to the customer search endpoint with starting_after" do
    client.expects(:post).with("/customers/search", { query: {}, pagination: { starting_after: "EnCrYpTeDsTrInG" }}).  returns(page_of_customers(false))
    client.customers.search(query: {}, starting_after: "EnCrYpTeDsTrInG").first
  end

  it "stops iterating if no starting_after value" do
    client.expects(:post).with("/customers/search", { query: {} }).  returns(page_of_customers(false))
    emails = []
    client.customers.search(query: {}).each { |user| emails << user.email }
    emails.must_equal %W(user1@example.com user2@example.com user3@example.com)
  end

  it "keeps iterating if starting_after value" do
    client.expects(:post).with("/customers/search", { query: {} }).returns(page_of_customers(true))
    client.expects(:post).with("/customers/search", { query: {}, pagination: { starting_after: "EnCrYpTeDsTrInG" }}).returns(page_of_customers(false))
    emails = []
    client.customers.search(query: {}).each { |user| emails << user.email }
  end

  it "supports indexed array access" do
    client.expects(:post).with("/customers/search", { query: {} }).returns(page_of_customers(false))
    client.customers.search(query: {})[0].email.must_equal 'user1@example.com'
  end

  it "supports map" do
    client.expects(:post).with("/customers/search", { query: {} }).returns(page_of_customers(false))
    emails = client.customers.search(query: {}).map { |user| user.email }
    emails.must_equal %W(user1@example.com user2@example.com user3@example.com)
  end

end
