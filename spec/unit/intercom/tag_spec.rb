# frozen_string_literal: true

require 'spec_helper'

describe 'Intercom::Tag' do
  let(:client) { Intercom::Client.new(token: 'token') }

  it 'creates a tag' do
    client.expects(:post).with('/tags', 'name' => 'Test Tag').returns(test_tag)
    tag = client.tags.create(name: 'Test Tag')
    _(tag.name).must_equal 'Test Tag'
  end

  it 'finds a tag by id' do
    client.expects(:get).with('/tags/4f73428b5e4dfc000b000112', {}).returns(test_tag)
    tag = client.tags.find(id: '4f73428b5e4dfc000b000112')
    _(tag.name).must_equal 'Test Tag'
  end

  it 'tags companies' do
    client.expects(:post).with('/tags', 'name' => 'Test Tag', 'companies' => [{ company_id: 'abc123' }, { company_id: 'def456' }], 'tag_or_untag' => 'tag').returns(test_tag)
    tag = client.tags.tag(name: 'Test Tag', companies: [{ company_id: 'abc123' }, { company_id: 'def456' }])
    _(tag.name).must_equal 'Test Tag'
    _(tag.tagged_company_count).must_equal 2
  end

  it 'untags companies' do
    client.expects(:post).with('/tags', 'name' => 'Test Tag', 'companies' => [{ company_id: 'abc123', untag: true }, { company_id: 'def456', untag: true }], 'tag_or_untag' => 'untag').returns(test_tag)
    client.tags.untag(name: 'Test Tag', companies: [{ company_id: 'abc123' }, { company_id: 'def456' }])
  end

  it 'delete tags' do
    tag = Intercom::Tag.new('id' => '1')
    client.expects(:delete).with('/tags/1', {}).returns(tag)
    client.tags.delete(tag)
  end
end
