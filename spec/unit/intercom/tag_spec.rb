require 'spec_helper'

describe "Intercom::Tag" do
  it "creates a tag" do
    Intercom.expects(:post).with("/v1/tags", {:name => "Test Tag"}).returns({"name" => "Test Tag", "color" => "green", "users" => []})
    tag = Intercom::Tag.create(:name => "Test Tag")
    tag.name.must_equal "Test Tag"
    tag.color.must_equal "green"
  end

  it "tags users" do
    Intercom.expects(:post).with("/v1/tags", {:name => "Test Tag", :color => "red", :user_ids => ["abc123", "def456"], :tag_or_untag => "tag"}).returns({"name" => "Test Tag", "color" => "red", "users" => [{"email" => "bob@example.com", "user_id" => "abc123"}, {"email" => "tom@example.com", "user_id" => "def456"}]})
    tag = Intercom::Tag.create(:name => "Test Tag", :color => "red", :user_ids => ["abc123", "def456"], :tag_or_untag => "tag")
    tag.name.must_equal "Test Tag"
    tag.color.must_equal "red"
    tag.users.must_equal [{"email" => "bob@example.com", "user_id" => "abc123"}, {"email" => "tom@example.com", "user_id" => "def456"}]
  end
end