require 'spec_helper'
require 'ostruct'

describe 'Intercom::Request' do
  it 'raises an error when a html error page rendered' do
    response = OpenStruct.new(:code => 500)
    req = Intercom::Request.new('path/', 'GET')
    proc {req.parse_body('<html>somethjing</html>', response)}.must_raise(Intercom::ServerError)
  end

  it 'parse_body returns nil if decoded_body is nil' do
    response = OpenStruct.new(:code => 500)
    req = Intercom::Request.new('path/', 'GET')
    req.parse_body(nil, response).must_equal(nil)
  end
end
