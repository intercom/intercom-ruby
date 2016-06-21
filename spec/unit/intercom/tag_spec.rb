require 'spec_helper'

describe "Intercom::Tag" do
  let (:client) { Intercom::Client.new(app_id: 'app_id',  api_key: 'api_key') }

  it "creates a tag" do
    client.expects(:post).with("/tags", {'name' => "Test Tag"}).returns(test_tag)
    tag = client.tags.create(:name => "Test Tag")
    tag.name.must_equal "Test Tag"
  end

  it "tags users" do
    client.expects(:post).with("/tags", {'name' => "Test Tag", 'users' => [ { user_id: 'abc123' }, { user_id: 'def456' } ], 'tag_or_untag' => 'tag'}).returns(test_tag)
    tag = client.tags.tag(:name => "Test Tag", :users => [ { user_id: "abc123" }, { user_id: "def456" } ] )
    tag.name.must_equal "Test Tag"
    tag.tagged_user_count.must_equal 2
  end

  it 'untags users' do
    client.expects(:post).with("/tags", {'name' => "Test Tag", 'users' => [ { user_id: 'abc123', untag: true }, { user_id: 'def456', untag: true } ], 'tag_or_untag' => 'untag'}).returns(test_tag)
    client.tags.untag(:name => "Test Tag", :users => [ { user_id: "abc123" }, { user_id: "def456" } ])
  end
end
