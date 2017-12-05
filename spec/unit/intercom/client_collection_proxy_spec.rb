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

  it "supports single page pagination" do
    users = [test_user("user1@example.com"), test_user("user2@example.com"), test_user("user3@example.com"),
     test_user("user4@example.com"), test_user("user5@example.com"), test_user("user6@example.com"),
     test_user("user7@example.com"), test_user("user8@example.com"), test_user("user9@example.com"),
     test_user("user10@example.com")]
    client.expects(:get).with("/users", {:type=>'users', :per_page => 10, :page => 1}).returns(users_pagination(include_next_link: false, per_page: 10, page: 1, total_pages: 1, total_count: 10, user_list: users))
    result = client.users.find_all(:type=>'users', :per_page => 10, :page => 1).map {|user| user.email }
    result.must_equal %W(user1@example.com user2@example.com user3@example.com user4@example.com user5@example.com user6@example.com user7@example.com user8@example.com user9@example.com user10@example.com)
  end

  it "supports multi page pagination" do
    users = [test_user("user3@example.com"), test_user("user4@example.com")]
    client.expects(:get).with("/users", {:type=>'users', :per_page => 2, :page => 3}).returns(users_pagination(include_next_link: true, per_page: 2, page: 3, total_pages: 5, total_count: 10, user_list: users))
    result = client.users.find_all(:type=>'users', :per_page => 2, :page => 3).map {|user| user.email }
    result.must_equal %W(user3@example.com user4@example.com)
  end

  it "works with page out of range request" do
    users = []
    client.expects(:get).with("/users", {:type=>'users', :per_page => 2, :page => 30}).returns(users_pagination(include_next_link: true, per_page: 2, page: 30, total_pages: 2, total_count: 3, user_list: users))
    result = client.users.find_all(:type=>'users', :per_page => 2, :page => 30).map {|user| user.email }
    result.must_equal %W()
  end

  it "works with asc order" do
    test_date=1457337600
    time_increment=1000
    users = [test_user_dates(email="user1@example.com", created_at=test_date), test_user_dates(email="user2@example.com", created_at=test_date-time_increment),
             test_user_dates(email="user3@example.com", created_at=test_date-2*time_increment), test_user_dates(email="user4@example.com", created_at=test_date-3*time_increment)]
    client.expects(:get).with("/users", {:type=>'users', :per_page => 4, :page => 5, :order => "asc", :sort => "created_at"}).returns(users_pagination(include_next_link: true, per_page: 4, page: 5, total_pages: 6, total_count: 30, user_list: users))
    result = client.users.find_all(:type=>'users', :per_page => 4, :page => 5, :order => "asc", :sort => "created_at").map(&:email)
    result.must_equal %W(user1@example.com user2@example.com user3@example.com user4@example.com)
  end

  it "works with desc order" do
    test_date=1457337600
    time_increment=1000
    users = [test_user_dates(email="user4@example.com", created_at=3*test_date), test_user_dates(email="user3@example.com", created_at=test_date-2*time_increment),
             test_user_dates(email="user2@example.com", created_at=test_date-time_increment), test_user_dates(email="user1@example.com", created_at=test_date)]
    client.expects(:get).with("/users", {:type=>'users', :per_page => 4, :page => 5, :order => "desc", :sort => "created_at"}).returns(users_pagination(include_next_link: true, per_page: 4, page: 5, total_pages: 6, total_count: 30, user_list: users))
    result = client.users.find_all(:type=>'users', :per_page => 4, :page => 5, :order => "desc", :sort => "created_at").map {|user| user.email }
    result.must_equal %W(user4@example.com user3@example.com user2@example.com user1@example.com)
  end

end
