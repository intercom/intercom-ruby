require 'spec_helper'

describe Intercom::Collection do
  let(:client) { Intercom::Client.new(token: 'token') }

  it 'creates a collection' do
    client.expects(:post).with('/help_center/collections', { 'name' => 'Collection 1', 'description' => 'Collection desc' }).returns(test_collection)
    client.collections.create(:name => 'Collection 1', :description => 'Collection desc')
  end

  it 'lists collections' do
    client.expects(:get).with('/help_center/collections', {}).returns(test_collection_list)
    client.collections.all.each { |t| }
  end

  it 'finds a collection' do
    client.expects(:get).with('/help_center/collections/1', {}).returns(test_collection)
    client.collections.find(id: '1')
  end

  it 'updates a collection' do
    collection = Intercom::Collection.new(id: '12345')
    client.expects(:put).with('/help_center/collections/12345', {})
    client.collections.save(collection)
  end

  it 'deletes a collection' do
    collection = Intercom::Collection.new(id: '12345')
    client.expects(:delete).with('/help_center/collections/12345', {})
    client.collections.delete(collection)
  end
end