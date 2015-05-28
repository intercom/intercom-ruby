require "spec_helper"

describe "Intercom::User" do
  let (:client) { Intercom::Client.new(app_id: 'app_id',  api_key: 'api_key') }

  it "to_hash'es itself" do
    created_at = Time.now
    user = Intercom::User.new(:email => "jim@example.com", :user_id => "12345", :created_at => created_at, :name => "Jim Bob")
    as_hash = user.to_hash
    as_hash["email"].must_equal "jim@example.com"
    as_hash["user_id"].must_equal "12345"
    as_hash["created_at"].must_equal created_at.to_i
    as_hash["name"].must_equal "Jim Bob"
  end

  it "presents created_at and last_impression_at as Date" do
    now = Time.now
    user = Intercom::User.from_api(:created_at => now, :last_impression_at => now)
    user.created_at.must_be_kind_of Time
    user.created_at.to_s.must_equal now.to_s
    user.last_impression_at.must_be_kind_of Time
    user.last_impression_at.to_s.must_equal now.to_s
  end

  it "is throws a Intercom::AttributeNotSetError on trying to access an attribute that has not been set" do
    user = Intercom::User.new
    proc { user.foo_property }.must_raise Intercom::AttributeNotSetError
  end

  it "presents a complete user record correctly" do
    user = Intercom::User.from_api(test_user)
    user.user_id.must_equal 'id-from-customers-app'
    user.email.must_equal 'bob@example.com'
    user.name.must_equal 'Joe Schmoe'
    user.app_id.must_equal 'the-app-id'
    user.session_count.must_equal 123
    user.created_at.to_i.must_equal 1401970114
    user.remote_created_at.to_i.must_equal 1393613864
    user.updated_at.to_i.must_equal 1401970114

    user.avatar.must_be_kind_of Intercom::Avatar
    user.avatar.image_url.must_equal 'https://graph.facebook.com/1/picture?width=24&height=24'

    user.companies.must_be_kind_of Array
    user.companies.size.must_equal 1
    user.companies[0].must_be_kind_of Intercom::Company
    user.companies[0].company_id.must_equal "123"
    user.companies[0].id.must_equal "bbbbbbbbbbbbbbbbbbbbbbbb"
    user.companies[0].app_id.must_equal "the-app-id"
    user.companies[0].name.must_equal "Company 1"
    user.companies[0].remote_created_at.to_i.must_equal 1390936440
    user.companies[0].created_at.to_i.must_equal 1401970114
    user.companies[0].updated_at.to_i.must_equal 1401970114
    user.companies[0].last_request_at.to_i.must_equal 1401970113
    user.companies[0].monthly_spend.must_equal 0
    user.companies[0].session_count.must_equal 0
    user.companies[0].user_count.must_equal 1
    user.companies[0].tag_ids.must_equal []

    user.custom_attributes.must_be_kind_of Intercom::Lib::FlatStore
    user.custom_attributes["a"].must_equal "b"
    user.custom_attributes["b"].must_equal 2

    user.social_profiles.size.must_equal 4
    twitter_account = user.social_profiles.first
    twitter_account.must_be_kind_of Intercom::SocialProfile
    twitter_account.name.must_equal "twitter"
    twitter_account.username.must_equal "abc"
    twitter_account.url.must_equal "http://twitter.com/abc"

    user.location_data.must_be_kind_of Intercom::LocationData
    user.location_data.city_name.must_equal "Dublin"
    user.location_data.continent_code.must_equal "EU"
    user.location_data.country_name.must_equal "Ireland"
    user.location_data.latitude.must_equal "90"
    user.location_data.longitude.must_equal "10"
    user.location_data.country_code.must_equal "IRL"

    user.unsubscribed_from_emails.must_equal true
    user.user_agent_data.must_equal "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_3) AppleWebKit/535.11 (KHTML, like Gecko) Chrome/17.0.963.56 Safari/535.11"
  end

  it 'allows update_last_request_at' do
    client.expects(:post).with("/users", {"user_id" => "1224242", 'update_last_request_at' => true, "custom_attributes" => {}}).returns({"user_id" => "i-1224242", "last_request_at" => 1414509439})
    client.users.create(user_id: '1224242', update_last_request_at: true)
  end

  it "allows easy setting of custom data" do
    now = Time.now
    user = Intercom::User.new
    user.custom_attributes["mad"] = 123
    user.custom_attributes["other"] = now.to_i
    user.custom_attributes["thing"] = "yay"
    user.to_hash["custom_attributes"].must_equal "mad" => 123, "other" => now.to_i, "thing" => "yay"
  end

  it "allows easy setting of multiple companies" do
    user = Intercom::User.new()
    companies = [
      {"name" => "Intercom", "company_id" => "6"},
      {"name" => "Test", "company_id" => "9"}
    ]
    user.companies = companies
    user.to_hash["companies"].must_equal companies
  end

  it "rejects nested data structures in custom_attributes" do
    user = Intercom::User.new()

    proc { user.custom_attributes["thing"] = [1] }.must_raise(ArgumentError)
    proc { user.custom_attributes["thing"] = {1 => 2} }.must_raise(ArgumentError)
    proc { user.custom_attributes["thing"] = {1 => {2 => 3}} }.must_raise(ArgumentError)

    user = Intercom::User.from_api(test_user)
    proc { user.custom_attributes["thing"] = [1] }.must_raise(ArgumentError)
  end

  describe "incrementing custom_attributes fields" do
    before :each do
      @now = Time.now
      @user = Intercom::User.new("email" => "jo@example.com", :user_id => "i-1224242", :custom_attributes => {"mad" => 123, "another" => 432, "other" => @now.to_i, :thing => "yay"})
    end

    it "increments up by 1 with no args" do
      @user.increment("mad")
      @user.to_hash["custom_attributes"]["mad"].must_equal 124
    end

    it "increments up by given value" do
      @user.increment("mad", 4)
      @user.to_hash["custom_attributes"]["mad"].must_equal 127
    end

    it "increments down by given value" do
      @user.increment("mad", -1)
      @user.to_hash["custom_attributes"]["mad"].must_equal 122
    end

    it "can increment new custom data fields" do
      @user.increment("new_field", 3)
      @user.to_hash["custom_attributes"]["new_field"].must_equal 3
    end

    it "can call increment on the same key twice and increment by 2" do
      @user.increment("mad")
      @user.increment("mad")
      @user.to_hash["custom_attributes"]["mad"].must_equal 125
    end
  end

  it "fetches a user" do
    client.expects(:get).with("/users", {"email" => "bo@example.com"}).returns(test_user)
    user = client.users.find("email" => "bo@example.com")
    user.email.must_equal "bob@example.com"
    user.name.must_equal "Joe Schmoe"
    user.session_count.must_equal 123
  end

  it 'gets users by tag' do
    client.expects(:get).with("/users?tag_id=124", {}).returns(page_of_users(false))
    client.users.by_tag(124).each { |t| }
  end

  it 'gets users by segment' do
    client.expects(:get).with("/users?segment_id=124", {}).returns(page_of_users(false))
    client.users.by_segment(124).each { |t| }
  end

  it "saves a user (always sends custom_attributes)" do
    user = Intercom::User.new("email" => "jo@example.com", :user_id => "i-1224242")
    client.expects(:post).with("/users", {"email" => "jo@example.com", "user_id" => "i-1224242", "custom_attributes" => {}}).returns({"email" => "jo@example.com", "user_id" => "i-1224242"})
    client.users.save(user)
  end

  it "saves a user with a company" do
    user = Intercom::User.new("email" => "jo@example.com", :user_id => "i-1224242", :company => {'company_id' => 6, 'name' => "Intercom"})
    client.expects(:post).with("/users", {'custom_attributes' => {}, "user_id" => "i-1224242", "email" => "jo@example.com", "company" => {"company_id" => 6, "name" => "Intercom"}}).returns({"email" => "jo@example.com", "user_id" => "i-1224242"})
    client.users.save(user)
  end

  it "saves a user with a companies" do
    user = Intercom::User.new("email" => "jo@example.com", :user_id => "i-1224242", :companies => [{'company_id' => 6, 'name' => "Intercom"}])
    client.expects(:post).with("/users", {'custom_attributes' => {}, "email" => "jo@example.com", "user_id" => "i-1224242", "companies" => [{"company_id" => 6, "name" => "Intercom"}]}).returns({"email" => "jo@example.com", "user_id" => "i-1224242"})
    client.users.save(user)
  end

  it 'can save a user with a nil email' do
    user = Intercom::User.new("email" => nil, :user_id => "i-1224242", :companies => [{'company_id' => 6, 'name' => "Intercom"}])
    client.expects(:post).with("/users", {'custom_attributes' => {}, "email" => nil, "user_id" => "i-1224242", "companies" => [{"company_id" => 6, "name" => "Intercom"}]}).returns({"email" => nil, "user_id" => "i-1224242"})
    client.users.save(user)
  end

  it "deletes a user" do
    user = Intercom::User.new("id" => "1")
    client.expects(:delete).with("/users/1", {}).returns(user)
    client.users.delete(user)
  end

  it "can use client.users.create for convenience" do
    client.expects(:post).with("/users", {'custom_attributes' => {}, "email" => "jo@example.com", "user_id" => "i-1224242"}).returns({"email" => "jo@example.com", "user_id" => "i-1224242"})
    user = client.users.create("email" => "jo@example.com", :user_id => "i-1224242")
    user.email.must_equal "jo@example.com"
  end

  it "updates the user with attributes as set by the server" do
    client.expects(:post).with("/users", {"email" => "jo@example.com", "user_id" => "i-1224242", 'custom_attributes' => {}}).returns({"email" => "jo@example.com", "user_id" => "i-1224242", "session_count" => 4})
    user = client.users.create("email" => "jo@example.com", :user_id => "i-1224242")
    user.session_count.must_equal 4
  end

  it "allows setting dates to nil without converting them to 0" do
    client.expects(:post).with("/users", {"email" => "jo@example.com", 'custom_attributes' => {}, "remote_created_at" => nil}).returns({"email" => "jo@example.com"})
    user = client.users.create("email" => "jo@example.com", "remote_created_at" => nil)
    user.remote_created_at.must_equal nil
  end

  it "sets/gets rw keys" do
    params = {"email" => "me@example.com", :user_id => "abc123", "name" => "Bob Smith", "last_seen_ip" => "1.2.3.4", "last_seen_user_agent" => "ie6", "created_at" => Time.now}
    user = Intercom::User.new(params)
    custom_attributes = (params.keys + ['custom_attributes']).map(&:to_s).sort
    user.to_hash.keys.sort.must_equal custom_attributes
    params.keys.each do |key|
      user.send(key).to_s.must_equal params[key].to_s
    end
  end

  it "will allow extra attributes in response from api" do
    user = Intercom::User.send(:from_api, {"new_param" => "some value"})
    user.new_param.must_equal "some value"
  end

  it "returns a ClientCollectionProxy for all without making any requests" do
    client.expects(:execute_request).never
    all = client.users.all
    all.must_be_instance_of(Intercom::ClientCollectionProxy)
  end

end
