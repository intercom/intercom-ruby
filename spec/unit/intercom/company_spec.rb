require "spec_helper"

describe Intercom::Company do
  let(:client) { Intercom::Client.new(token: 'token') }

  describe "when no response raises error" do
    it "on find" do
      client.expects(:get).with("/companies", {:company_id => "4"}).returns(nil)
      _(proc { client.companies.find(:company_id => "4")}).must_raise Intercom::HttpError
    end

    it "on find_all" do
      client.expects(:get).with("/companies", {}).returns(nil)
      _(proc { client.companies.all.each {|company| }}).must_raise Intercom::HttpError
    end

    it "on load" do
      client.expects(:get).with("/companies", {:company_id => "4"}).returns({"type" =>"user", "id" =>"aaaaaaaaaaaaaaaaaaaaaaaa", "company_id" => "4", "name" => "MyCo"})
      company = client.companies.find(:company_id => "4")
      client.expects(:get).with("/companies/aaaaaaaaaaaaaaaaaaaaaaaa", {}).returns(nil)
      _(proc { client.companies.load(company)}).must_raise Intercom::HttpError
    end
  end

  it "finds a company" do
    client.expects(:get).with("/companies/531ee472cce572a6ec000006", {}).returns(test_company)
    company = client.companies.find(id: "531ee472cce572a6ec000006")
    _(company.name).must_equal("Blue Sun")
  end

  it "returns a collection proxy for listing contacts" do
    company = Intercom::Company.new("id" => "1")
    proxy = company.contacts
    _(proxy.resource_name).must_equal 'contacts'
    _(proxy.url).must_equal '/companies/1/contacts'
    _(proxy.resource_class).must_equal Intercom::Contact
  end
end
