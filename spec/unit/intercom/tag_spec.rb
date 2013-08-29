require 'spec_helper'

describe "Intercom::Tag" do
  it "gets a tag" do
    Intercom.expects(:get).with("/v1/tags", {:name => "Test Tag"}).returns(test_tag)
    tag = Intercom::Tag.find(:name => "Test Tag")
    tag.name.must_equal "Test Tag"
  end

  it "creates a tag" do
    Intercom.expects(:post).with("/v1/tags", {:name => "Test Tag"}).returns(test_tag)
    tag = Intercom::Tag.create(:name => "Test Tag")
    tag.name.must_equal "Test Tag"
  end

  it "tags users" do
    Intercom.expects(:post).with("/v1/tags", {:name => "Test Tag", :user_ids => ["abc123", "def456"], :tag_or_untag => "tag"}).returns(test_tag)
    tag = Intercom::Tag.create(:name => "Test Tag", :user_ids => ["abc123", "def456"], :tag_or_untag => "tag")
    tag.name.must_equal "Test Tag"
    tag.tagged_user_count.must_equal 2
  end

end