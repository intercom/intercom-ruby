require "spec_helper"

describe Intercom::BaseCollectionProxy do
  let(:client) { Intercom::Client.new(token: 'token') }

  it "stops iterating if no starting after value" do
    client.expects(:get).with("/contacts", {}). returns(page_of_contacts(false))
    emails = []
    client.contacts.all.each { |contact| emails << contact.email }
    _(emails).must_equal %w[test1@example.com test2@example.com test3@example.com]
  end

  it "keeps iterating if starting after value" do
    client.expects(:get).with("/contacts", {}).returns(page_of_contacts(true))
    client.expects(:get).with('/contacts', { starting_after: "EnCrYpTeDsTrInG" }).returns(page_of_contacts(false))
    emails = []
    client.contacts.all.each { |contact| emails << contact.email }
  end

  it "supports indexed array access" do
    client.expects(:get).with("/contacts", {}).returns(page_of_contacts(false))
    _(client.contacts.all[0].email).must_equal "test1@example.com"
  end

  it "supports map" do
    client.expects(:get).with("/contacts", {}).returns(page_of_contacts(false))
    emails = client.contacts.all.map { |contact| contact.email }
    _(emails).must_equal %w[test1@example.com test2@example.com test3@example.com]
  end
end
