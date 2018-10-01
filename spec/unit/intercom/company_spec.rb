require 'spec_helper'

describe Intercom::Company do
  let (:client) { Intercom::Client.new(app_id: 'app_id',  api_key: 'api_key') }

  describe 'when no response raises error' do
    it 'on find' do
      client.expects(:get).with("/companies", {:company_id => '4'}).returns(nil)
      proc {client.companies.find(:company_id => '4')}.must_raise Intercom::HttpError
    end

    it 'on find_all' do
      client.expects(:get).with("/companies", {}).returns(nil)
      proc {client.companies.all.each {|company| }}.must_raise Intercom::HttpError
    end

    it 'on load' do
      client.expects(:get).with("/companies", {:company_id => '4'}).returns({'type' =>'user', 'id' =>'aaaaaaaaaaaaaaaaaaaaaaaa', 'company_id' => '4', 'name' => 'MyCo'})
      company = client.companies.find(:company_id => '4')
      client.expects(:get).with('/companies/aaaaaaaaaaaaaaaaaaaaaaaa', {}).returns(nil)
      proc {client.companies.load(company)}.must_raise Intercom::HttpError
    end
  end

  it 'gets users in a company' do
    client.expects(:get).with("/companies/abc123/users", {}).returns(page_of_users(false))
    client.companies.users(id: 'abc123').each do |u|
    end
  end

  it 'finds a company' do
    client.expects(:get).with("/companies/531ee472cce572a6ec000006", {}).returns(test_company)
    company = client.companies.find(id: '531ee472cce572a6ec000006')
    company.name.must_equal("Blue Sun")
  end
end
