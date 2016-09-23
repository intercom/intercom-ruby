require "spec_helper"

describe "Intercom::Admin" do
  let (:client) { Intercom::Client.new(app_id: 'app_id',  api_key: 'api_key') }

  it "returns a CollectionProxy for all without making any requests" do
    client.expects(:execute_request).never
    all = client.admins.all
    all.must_be_instance_of(Intercom::ClientCollectionProxy)
  end

  it 'gets an admin list' do
    client.expects(:get).with("/admins", {}).returns(test_admin_list)
    client.admins.all.each { |a| }
  end

  it "gets an admin" do
    client.expects(:get).with("/admins/1234", {}).returns(test_admin)
    client.admins.find(:id => "1234")
  end
end
