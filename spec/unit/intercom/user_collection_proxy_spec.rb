require "spec_helper"

describe Intercom::UserCollectionProxy do
  before :each do
    Intercom.expects(:execute_request).never
  end

  it "supports each" do
    Intercom.expects(:get).with("/v1/users", {:page => 1}).returns(page_of_users)
    emails = []
    Intercom::User.all.each { |user| emails << user.email }
    emails.must_equal %W(user1@example.com user2@example.com user3@example.com)
  end

  it "supports querying for tagged users" do
    Intercom.expects(:get).with("/v1/users", {:tag_id => "1234", :page => 1}).returns(page_of_users)
    emails = []
    Intercom::User.where(:tag_id => '1234').each { |user| emails << user.email }
    emails.must_equal %W(user1@example.com user2@example.com user3@example.com)
  end

  it "should only pass whitelisted attributes to collection query" do
    Intercom.expects(:get).with("/v1/users", {:tag_name => '1234', :page => 1}).returns(page_of_users)
    emails = []
    Intercom::User.where(:danger_zone => 'BOOM', :tag_name => '1234').each { |user| emails << user.email }
    emails.must_equal %W(user1@example.com user2@example.com user3@example.com)
  end

  it "supports map" do
    Intercom.expects(:get).with("/v1/users", {:page => 1}).returns(page_of_users).twice
    Intercom::User.all.map { |user| user.email }.must_equal %W(user1@example.com user2@example.com user3@example.com)
    Intercom::User.all.collect { |user| user.email }.must_equal %W(user1@example.com user2@example.com user3@example.com)
  end

  it "loads multiple pages" do
    Intercom.expects(:get).with("/v1/users", {:page => 1}).returns(page_of_users(1, 1))
    Intercom.expects(:get).with("/v1/users", {:page => 2}).returns(page_of_users(2, 1))
    Intercom.expects(:get).with("/v1/users", {:page => 3}).returns(page_of_users(3, 1))
    Intercom::User.all.map { |user| user.email }.must_equal %W(user1@example.com user2@example.com user3@example.com)
  end

  it "only loads the first page when counting" do
    Intercom.expects(:get).with("/v1/users", {:per_page => 1}).returns(page_of_users(1, 1))
    Intercom::User.all.count.must_equal(3)
  end
end