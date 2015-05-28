require "spec_helper"

describe Intercom::ClientCollectionProxy do
  let (:client) { Intercom::Client.new(app_id: 'app_id',  api_key: 'api_key') }

  it "stops iterating if no next link" do
    client.expects(:get).with("/users", {}).returns(page_of_users(false))
    emails = []
    client.users.all.each { |user| emails << user.email }
    emails.must_equal %W(user1@example.com user2@example.com user3@example.com)
  end

  it "keeps iterating if next link" do
    client.expects(:get).with("/users", {}).returns(page_of_users(true))
    client.expects(:get).with('https://api.intercom.io/users?per_page=50&page=2', {}).returns(page_of_users(false))
    emails = []
    client.users.all.each { |user| emails << user.email }
  end

  it "supports indexed array access" do
    client.expects(:get).with("/users", {}).returns(page_of_users(false))
    client.users.all[0].email.must_equal 'user1@example.com'
  end

  it "supports map" do
    client.expects(:get).with("/users", {}).returns(page_of_users(false))
    emails = client.users.all.map { |user| user.email }
    emails.must_equal %W(user1@example.com user2@example.com user3@example.com)
  end

  it "supports querying" do
    client.expects(:get).with("/users", {:tag_name => 'Taggart J'}).returns(page_of_users(false))
    client.users.find_all(:tag_name => 'Taggart J').map(&:email).must_equal %W(user1@example.com user2@example.com user3@example.com)
  end
end
