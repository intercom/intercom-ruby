require 'spec_helper'

describe Intercom::Company do
  
  describe 'when no response raises error' do
    it 'on find' do
      Intercom.expects(:get).with("/companies", {:company_id => '4'}).returns(nil)
      proc {Intercom::Company.find(:company_id => '4')}.must_raise Intercom::HttpError
    end
    
    it 'on find_all' do
      Intercom.expects(:get).with("/companies", {}).returns(nil)
      proc {Intercom::Company.all.each {|company| }}.must_raise Intercom::HttpError
    end
    
    it 'on load' do
      Intercom.expects(:get).with("/companies", {:company_id => '4'}).returns({'type' =>'user', 'id' =>'aaaaaaaaaaaaaaaaaaaaaaaa', 'company_id' => '4', 'name' => 'MyCo'})
      company = Intercom::Company.find(:company_id => '4')
      Intercom.expects(:get).with('/companies/aaaaaaaaaaaaaaaaaaaaaaaa', {}).returns(nil)
      proc {company.load}.must_raise Intercom::HttpError
    end
  end
end
