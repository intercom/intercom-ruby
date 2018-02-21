require "spec_helper"

describe "Intercom::Visitors" do
  let (:client) { Intercom::Client.new(app_id: 'app_id',  api_key: 'api_key') }

  it 'should be listable' do
    proxy = client.visitors.all
    proxy.resource_name.must_equal 'visitors'
    proxy.finder_url.must_equal '/visitors'
    proxy.resource_class.must_equal Intercom::Visitor
  end

  it 'can update a visitor with an id' do
    visitor = Intercom::Visitor.new(:id => "de45ae78gae1289cb")
    client.expects(:put).with("/visitors/de45ae78gae1289cb", {'custom_attributes' => {}})
    client.visitors.save(visitor)
  end

  describe 'converting' do
    let(:visitor) { Intercom::Visitor.from_api(user_id: 'visitor_id') }
    let(:user) { Intercom::User.from_api(id: 'user_id') }

    it 'visitor to user' do
      client.expects(:post).with(
        "/visitors/convert",
        {
          visitor: { user_id: visitor.user_id },
          user: { 'id' => user.id },
          type:'user'
        }
      ).returns(test_user)

      client.visitors.convert(visitor, user)
    end

    it 'visitor to lead' do
      client.expects(:post).with(
        "/visitors/convert",
        {
          visitor: { user_id: visitor.user_id },
          type:'lead'
        }
      ).returns(test_user)

      client.visitors.convert(visitor)
    end
  end

  it "returns a ClientCollectionProxy for all without making any requests" do
    client.expects(:execute_request).never
    all = client.visitors.all
    all.is_a?(Intercom::ClientCollectionProxy)
  end

  it "deletes a visitor" do
    visitor = Intercom::Visitor.new("id" => "1")
    client.expects(:delete).with("/visitors/1", {}).returns(visitor)
    client.visitors.delete(visitor)
  end

end
