require "spec_helper"

describe "Intercom::Count" do
  let (:client) { Intercom::Client.new(app_id: 'app_id',  api_key: 'api_key') }

  it 'should get app wide counts' do
    client.expects(:get).with("/counts", {}).returns(test_app_count)
    counts = client.counts.for_app
    counts.tag['count'].must_equal(341)
  end

  it 'should get type counts' do
    client.expects(:get).with("/counts", {type: 'user', count: 'segment'}).returns(test_segment_count)
    counts = client.counts.for_type(type: 'user', count: 'segment')
    counts.user['segment'][4]["segment 1"].must_equal(1)
  end

  it 'should not include count param when nil' do
    client.expects(:get).with("/counts", {type: 'conversation'}).returns(test_segment_count)
    counts = client.counts.for_type(type: 'conversation')
    counts.user['segment'][4]["segment 1"].must_equal(1)
  end
end
