require "spec_helper"

describe "Intercom::Team" do
  let (:client) { Intercom::Client.new(token: 'token') }

  it "returns a CollectionProxy for all without making any requests" do
    client.expects(:execute_request).never
    all = client.teams.all
    all.must_be_instance_of(Intercom::ClientCollectionProxy)
  end

  it 'gets an team list' do
    client.expects(:get).with("/teams", {}).returns(test_team_list)
    client.teams.all.each { |t| }
  end

  it "gets an team" do
    client.expects(:get).with("/teams/1234", {}).returns(test_team)
    client.teams.find(:id => "1234")
  end
end