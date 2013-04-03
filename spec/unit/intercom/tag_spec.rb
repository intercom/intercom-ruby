require 'spec_helper'

describe "Intercom::Tag" do
  it "gets a tag" do
    Intercom.expects(:get).with("/v1/tags", {:name => "Test Tag"}).returns(test_tag)
    tag = Intercom::Tag.find(:name => "Test Tag")
    tag.name.must_equal "Test Tag"
    tag.color.must_equal "red"
  end

  it "gets a tag by name" do
    Intercom.expects(:get).with("/v1/tags", {:name => "Test Tag"}).returns(test_tag)
    tag = Intercom::Tag.find_by_name "Test Tag"
    tag.name.must_equal "Test Tag"
    tag.color.must_equal "red"
  end

  it "creates a tag" do
    Intercom.expects(:post).with("/v1/tags", {:name => "Test Tag"}).returns(test_tag)
    tag = Intercom::Tag.create(:name => "Test Tag")
    tag.name.must_equal "Test Tag"
    tag.color.must_equal "red"
  end

  it "tags users" do
    Intercom.expects(:post).with("/v1/tags", {:name => "Test Tag", :color => "red", :user_ids => ["abc123", "def456"], :tag_or_untag => "tag"}).returns(test_tag)
    tag = Intercom::Tag.create(:name => "Test Tag", :color => "red", :user_ids => ["abc123", "def456"], :tag_or_untag => "tag")
    tag.name.must_equal "Test Tag"
    tag.color.must_equal "red"
    tag.users.must_equal [{"email" => "bob@example.com", "user_id" => "abc123"}, {"email" => "tom@example.com", "user_id" => "def456"}]
  end
end