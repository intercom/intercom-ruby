require "spec_helper"

describe "Intercom::User" do
  it "to_hash'es itself" do
    created_at = Time.now
    user = Intercom::User.new("email" => "jim@example.com", :user_id => "12345", :created_at => created_at, :name => "Jim Bob")
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

  it "is ok on missing methods" do
    user = Intercom::User.new
    user.created_at.must_be_nil
    user.last_impression_at.must_be_nil
    user.email.must_be_nil
    user.social_profiles.must_equal([])
  end

  it "presents a complete user record correctly" do
    user = Intercom::User.from_api(test_user)
    user.session_count.must_equal 123
    user.social_profiles.size.must_equal 4
    twitter_account = user.social_profiles.first
    twitter_account.must_be_kind_of Intercom::SocialProfile
    twitter_account.type.must_equal "twitter"
    twitter_account.username.must_equal "abc"
    twitter_account.url.must_equal "http://twitter.com/abc"
    user.custom_data["a"].must_equal "b"
    user.custom_data["b"].must_equal 2
    user.relationship_score.must_equal 90
    user.last_seen_ip.must_equal "1.2.3.4"
    user.last_seen_user_agent.must_equal "Mozilla blah blah ie6"
    user.avatar_url.must_equal "http://google.com/logo.png"
    user.unsubscribed_from_emails.must_equal true
    user.location_data['country_code'].must_equal "IRL"
  end

  it "has read-only social accounts" do
    user = Intercom::User.new(:social_profiles => ["url" => "http://twitter.com/abc", "username" => "abc", "type" => "twitter"])
    user.social_profiles.size.must_equal 1
    twitter = user.social_profiles.first
    twitter.type.must_equal "twitter"
    twitter.url.must_equal "http://twitter.com/abc"
    twitter.username.must_equal "abc"
    user.to_hash["social_profiles"].must_equal nil
    proc { user.social_profiles << "a" }.must_raise error_on_modify_frozen, "can't modify frozen array"
    proc { Intercom::User.new.social_profiles << "a" }.must_raise error_on_modify_frozen, "can't modify frozen array"
  end

  it "has read-only location data" do
    Intercom::User.new.location_data.must_equal({})
    user = Intercom::User.new(:location_data => {"city" => "Dublin"})
    user.location_data.must_equal({"city" => "Dublin"})
    proc { user.location_data["change"] = "123" }.must_raise error_on_modify_frozen, "can't modify frozen hash"
    user.to_hash["location_data"].must_equal nil
  end

  it "allows easy setting of custom data" do
    now = Time.now
    user = Intercom::User.new()
    user.custom_data["mad"] = 123
    user.custom_data["other"] = now.to_i
    user.custom_data["thing"] = "yay"
    user.to_hash["custom_data"].must_equal "mad" => 123, "other" => now.to_i, "thing" => "yay"
  end

  it "allows easy setting of company data" do
    user = Intercom::User.new()
    user.company["name"] = "Intercom"
    user.company["id"] = 6
    user.to_hash["company"].must_equal "name" => "Intercom", "id" => 6
  end

  it "allows easy setting of multiple companies" do
    user = Intercom::User.new()
    companies = [
      {"name" => "Intercom", "id" => "6"},
      {"name" => "Test", "id" => "9"}
    ]
    user.companies = companies
    user.to_hash["companies"].must_equal companies
  end

  it "rejects setting companies without an array of hashes" do
    user = Intercom::User.new()
    proc { user.companies = {"name" => "test"} }.must_raise ArgumentError
    proc { user.companies = [ ["name", "test"] ]}.must_raise ArgumentError
  end

  it "rejects nested data structures in custom_data" do
    user = Intercom::User.new()
    proc { user.custom_data["thing"] = [1] }.must_raise ArgumentError
    proc { user.custom_data["thing"] = {1 => 2} }.must_raise ArgumentError
    proc { user.custom_data = {1 => {2 => 3}} }.must_raise ArgumentError

    user = Intercom::User.from_api(test_user)
    proc { user.custom_data["thing"] = [1] }.must_raise ArgumentError
  end

  describe "incrementing custom_data fields" do
    before :each do
      @now = Time.now
      @user = Intercom::User.new("email" => "jo@example.com", :user_id => "i-1224242", :custom_data => {"mad" => 123, "another" => 432, "other" => @now.to_i, :thing => "yay"})
    end

    it "increments up by 1 with no args" do
      @user.increment("mad")
      @user.to_hash["increments"].must_equal "mad" => 1
    end

    it "increments up by given value" do
      @user.increment("mad", 4)
      @user.to_hash["increments"].must_equal "mad" => 4
    end

    it "increments down by given value" do
      @user.increment("mad", -1)
      @user.to_hash["increments"].must_equal "mad" => -1
    end

    it "doesn't allow direct access to increments hash" do
      proc { @user.increments["mad"] = 1 }.must_raise NoMethodError
      proc { @user.increments }.must_raise NoMethodError
    end

    it "can update the increments hash without losing previous changes" do
      @user.increment("mad")
      @user.to_hash["increments"].must_equal "mad" => 1
      @user.increment("another", -2)
      @user.to_hash["increments"].must_equal "mad" => 1, "another" => -2
    end

    it "can increment new custom data fields" do
      @user.increment("new_field", 3)
      @user.to_hash["increments"].must_equal "new_field" => 3
    end

    it "can call increment on the same key twice and increment by 2" do
      @user.increment("mad")
      @user.increment("mad")
      @user.to_hash["increments"].must_equal "mad" => 2
    end
  end

  it "fetches a user" do
    Intercom.expects(:get).with("/v1/users", {"email" => "bo@example.com"}).returns(test_user)
    user = Intercom::User.find("email" => "bo@example.com")
    user.email.must_equal "bob@example.com"
    user.name.must_equal "Joe Schmoe"
    user.session_count.must_equal 123
  end

  it "saves a user" do
    user = Intercom::User.new("email" => "jo@example.com", :user_id => "i-1224242")
    Intercom.expects(:post).with("/v1/users", {"email" => "jo@example.com", "user_id" => "i-1224242"}).returns({"email" => "jo@example.com", "user_id" => "i-1224242"})
    user.save
  end

  it "saves a user with a company" do
    user = Intercom::User.new("email" => "jo@example.com", :user_id => "i-1224242", :company => {:id => 6, :name => "Intercom"})
    Intercom.expects(:post).with("/v1/users", {"email" => "jo@example.com", "user_id" => "i-1224242", "company" => {"id" => 6, "name" => "Intercom"}}).returns({"email" => "jo@example.com", "user_id" => "i-1224242"})
    user.save
  end

  it "saves a user with a companies" do
    user = Intercom::User.new("email" => "jo@example.com", :user_id => "i-1224242", :companies => [{:id => 6, :name => "Intercom"}])
    Intercom.expects(:post).with("/v1/users", {"email" => "jo@example.com", "user_id" => "i-1224242", "companies" => [{"id" => 6, "name" => "Intercom"}]}).returns({"email" => "jo@example.com", "user_id" => "i-1224242"})
    user.save
  end

  it "deletes a user" do
    Intercom.expects(:delete).with("/v1/users", {"email" => "jo@example.com", "user_id" => "i-1224242"}).returns({"email" => "jo@example.com", "user_id" => "i-1224242"})
    Intercom::User.delete("email" => "jo@example.com", "user_id" => "i-1224242")
  end

  it "can use User.create for convenience" do
    Intercom.expects(:post).with("/v1/users", {"email" => "jo@example.com", "user_id" => "i-1224242"}).returns({"email" => "jo@example.com", "user_id" => "i-1224242"})
    user = Intercom::User.create("email" => "jo@example.com", :user_id => "i-1224242")
    user.email.must_equal "jo@example.com"
  end

  it "updates the @user with attributes as set by the server" do
    Intercom.expects(:post).with("/v1/users", {"email" => "jo@example.com", "user_id" => "i-1224242"}).returns({"email" => "jo@example.com", "user_id" => "i-1224242", "session_count" => 4})
    user = Intercom::User.create("email" => "jo@example.com", :user_id => "i-1224242")
    user.session_count.must_equal 4
  end

  it "raises argument error when trying to set a read only attribute" do
    read_only_attributes = %w(relationship_score session_count)
    read_only_attributes.each do |read_only|
      proc { Intercom::User.create("email" => "jo@example.com", read_only => "some value") }.must_raise NoMethodError
      user = Intercom::User.new
      user.public_methods.include?("#{read_only}=").must_equal false
    end
  end

  it "allows setting dates to nil without converting them to 0" do
    Intercom.expects(:post).with("/v1/users", {"email" => "jo@example.com", "created_at" => nil}).returns({"email" => "jo@example.com"})
    user = Intercom::User.create("email" => "jo@example.com", "created_at" => nil)
    user.created_at.must_equal nil
  end

  it "sets/gets rw keys" do
    params = {"email" => "me@example.com", :user_id => "abc123", "name" => "Bob Smith", "last_seen_ip" => "1.2.3.4", "last_seen_user_agent" => "ie6", "created_at" => Time.now}
    user = Intercom::User.new(params)
    user.to_hash.keys.sort.must_equal params.keys.map(&:to_s).sort
    params.keys.each do |key|
      user.send(key).to_s.must_equal params[key].to_s
    end
  end

  it "will allow extra attributes in response from api" do
    user = Intercom::User.send(:from_api, {"new_param" => "some value"})
    user.new_param.must_equal "some value"
  end

  it "returns a UserCollectionProxy for all without making any requests" do
    Intercom.expects(:execute_request).never
    all = Intercom::User.all
    all.must_be_instance_of(Intercom::UserCollectionProxy)
  end

  it "returns the total number of users" do
    Intercom.expects(:get).with("/v1/users", {:per_page => 1}).returns(page_of_users)
    Intercom::User.count.must_be_kind_of(Integer)
  end

  it "can find_by_email" do
    Intercom::User.expects(:find).with(:email => "bob@example.com")
    Intercom::User.find_by_email("bob@example.com")
  end

  it "can find_by_user_id" do
    Intercom::User.expects(:find).with(:user_id => "abc123")
    Intercom::User.find_by_user_id("abc123")
  end

  it "converts company created_at values to unix timestamps" do
    time = Time.now

    user = Intercom::User.new("companies" => [
      { "created_at" => time },
      { "created_at" => time.to_i }
    ])

    as_hash = user.to_hash
    first_company_as_hash = as_hash["companies"][0]
    second_company_as_hash = as_hash["companies"][1]

    first_company_as_hash["created_at"].must_equal time.to_i
    second_company_as_hash["created_at"].must_equal time.to_i
  end

  it "creates a note" do
    Intercom.expects(:post).with("/v1/users/notes", {'email' => 'bob@example.com', "body" => "Note to leave on user"}).returns({"html" => "<p>Note to leave on user</p>", "created_at" => 1234567890})
    user = Intercom::User.from_api(test_user)
    note = user.add_note("Note to leave on user")
    note.html.must_equal "<p>Note to leave on user</p>"
  end
end
