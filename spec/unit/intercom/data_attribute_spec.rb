require "spec_helper"

describe "Intercom::DataAttribute" do
  let (:client) { Intercom::Client.new(app_id: 'app_id', api_key: 'api_key') }

  it "returns a CollectionProxy for all without making any requests" do
    client.expects(:execute_request).never
    all = client.data_attributes.all
    _(all).must_be_instance_of(Intercom::ClientCollectionProxy)
  end


  it "creates a new data attribute" do
    client.expects(:post).with("/data_attributes", { "name" => "blah", "model" => "contact", "data_type" => "string" }).returns(status: 200)
    client.data_attributes.create("name": "blah",
                                  "model": "contact",
                                  "data_type": "string" )
  end

  it "updates an existing attribute" do
    attribute = Intercom::DataAttribute.new("id": 123,
                                            "name": "blah",
                                            "model": "contact",
                                            "data_type": "string")
    client.expects(:put).with("/data_attributes/#{attribute.id}", { "name" => "New name", "model" => "contact", "data_type" => "string" })
    attribute.name = "New name"
    client.data_attributes.save(attribute)
    _(attribute.name).must_equal "New name"
  end

  it 'gets a list of attributes' do
    client.expects(:get).with("/data_attributes", {}).returns(test_data_attribute_list)
    client.data_attributes.all.each { |d| }
  end

  it 'finds all customer or company attributes' do
    client.expects(:get).with("/data_attributes", { "model": "contact" }).returns(test_data_attribute_list)
    client.data_attributes.find_all({"model": "contact"}).each { |d| }
  end
end
