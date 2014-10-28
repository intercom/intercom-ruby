require "spec_helper"

describe Intercom::CollectionProxy do

  it "stops iterating if no next link" do
    Intercom.expects(:get).with("/users", {}).returns(page_of_users(false))
    emails = []
    Intercom::User.all.each { |user| emails << user.email }
    emails.must_equal %W(user1@example.com user2@example.com user3@example.com)
  end

  it "keeps iterating if next link" do
    Intercom.expects(:get).with("/users", {}).returns(page_of_users(true))
    Intercom.expects(:get).with('https://api.intercom.io/users?per_page=50&page=2', {}).returns(page_of_users(false))
    emails = []
    Intercom::User.all.each { |user| emails << user.email }
  end

  it "supports indexed array access" do
    Intercom.expects(:get).with("/users", {}).returns(page_of_users(false))
    Intercom::User.all[0].email.must_equal 'user1@example.com'
  end

  it "supports map" do
    Intercom.expects(:get).with("/users", {}).returns(page_of_users(false))
    emails = Intercom::User.all.map { |user| user.email }
    emails.must_equal %W(user1@example.com user2@example.com user3@example.com)
  end

  it "supports querying" do
    Intercom.expects(:get).with("/users", {:tag_name => 'Taggart J'}).returns(page_of_users(false))
    Intercom::User.find_all(:tag_name => 'Taggart J').map(&:email).must_equal %W(user1@example.com user2@example.com user3@example.com)
  end
end
