require "spec_helper"

describe Intercom::ScrollCollectionProxy do
  let (:client) { Intercom::Client.new(app_id: 'app_id',  api_key: 'api_key') }

  it "stops iterating if no users returned" do
    client.expects(:get).with("/users/scroll", '').returns(users_scroll(false))
    emails = []
    client.users.scroll.each { |user| emails << user.email }
    emails.must_equal %W()
  end

  it "keeps iterating if users returned" do
    client.expects(:get).with("/users/scroll", '').returns(users_scroll(true))
    client.expects(:get).with('/users/scroll', {:scroll_param => 'da6bbbac-25f6-4f07-866b-b911082d7'}).returns(users_scroll(false))
    emails = []
    client.users.scroll.each { |user| emails << user.email }
  end

  it "supports indexed array access" do
    client.expects(:get).with("/users/scroll", '').returns(users_scroll(true))
    client.users.scroll[0].email.must_equal 'user1@example.com'
  end

  it "supports map" do
    client.expects(:get).with("/users/scroll", '').returns(users_scroll(true))
    client.expects(:get).with('/users/scroll', {:scroll_param => 'da6bbbac-25f6-4f07-866b-b911082d7'}).returns(users_scroll(false))
    emails = client.users.scroll.map { |user| user.email }
    emails.must_equal %W(user1@example.com user2@example.com user3@example.com)
  end

  it "returns one page scroll" do
    client.expects(:get).with("/users/scroll", '').returns(users_scroll(true))
    users = client.users.scroll.next
    emails = []
    users['users'].each {|usr| emails << usr.email}
    emails.must_equal %W(user1@example.com user2@example.com user3@example.com)
  end

  it "keeps iterating if called with scroll_param" do
    client.expects(:get).with("/users/scroll", '').returns(users_scroll(true))
    client.expects(:get).with('/users/scroll', {:scroll_param => 'da6bbbac-25f6-4f07-866b-b911082d7'}).returns(users_scroll(true))
    users = client.users.scroll.next
    users = client.users.scroll.next('da6bbbac-25f6-4f07-866b-b911082d7')
    emails =[]
    users['users'].each {|usr| puts usr.email}
  end

  it "works with an empty list" do
    client.expects(:get).with("/users/scroll", '').returns(users_scroll(false))
    users = client.users.scroll.next
    emails = []
    users['users'].each {|usr| emails << usr.email}
    emails.must_equal %W()
  end
end
