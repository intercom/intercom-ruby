require 'spec_helper'

describe "Intercom::Segment" do

  let(:client) { Intercom::Client.new(token: 'token') }

  it 'lists segments' do
    client.expects(:get).with('/segments', {}).returns(segment_list)
    segments = client.segments.all.to_a
    _(segments[0].name).must_equal('Active')
  end
end
