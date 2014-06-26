require "spec_helper"

describe "Intercom::Admin" do
  it "returns a CollectionProxy for all without making any requests" do
    Intercom.expects(:execute_request).never
    all = Intercom::Admin.all
    all.must_be_instance_of(Intercom::CollectionProxy)
  end
end