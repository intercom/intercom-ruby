require 'spec_helper'

describe Intercom::Section do
  let(:client) { Intercom::Client.new(token: 'token') }

  it 'creates a section' do
    client.expects(:post).with('/help_center/sections', { 'name' => 'Section 1', 'parent_id' => '1' }).returns(test_section)
    client.sections.create(:name => 'Section 1', :parent_id => '1')
  end

  it 'lists sections' do
    client.expects(:get).with('/help_center/sections', {}).returns(test_section_list)
    client.sections.all.each { |t| }
  end

  it 'finds a section' do
    client.expects(:get).with('/help_center/sections/1', {}).returns(test_section)
    client.sections.find(id: '1')
  end

  it 'updates a section' do
    section = Intercom::Section.new(id: '12345')
    client.expects(:put).with('/help_center/sections/12345', {})
    client.sections.save(section)
  end

  it 'deletes a section' do
    section = Intercom::Section.new(id: '12345')
    client.expects(:delete).with('/help_center/sections/12345', {})
    client.sections.delete(section)
  end
end