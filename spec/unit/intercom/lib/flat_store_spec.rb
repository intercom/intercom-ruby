# frozen_string_literal: true

require 'spec_helper'

describe Intercom::Lib::FlatStore do
  it 'raises if you try to set arrays but allows hashes' do
    data = Intercom::Lib::FlatStore.new
    _(proc { data['thing'] = [1] }).must_raise ArgumentError
  
    data['thing'] = { 'key' => 'value' }
    _(data['thing']).must_equal({ 'key' => 'value' })
    
    flat_store = Intercom::Lib::FlatStore.new('custom_object' => { 'type' => 'Order.list', 'instances' => [{'id' => '123'}] })
    _(flat_store['custom_object']).must_equal({ 'type' => 'Order.list', 'instances' => [{'id' => '123'}] })
  end

  it 'raises if you try to use a non string key' do
    data = Intercom::Lib::FlatStore.new
    _(proc { data[1] = 'something' }).must_raise ArgumentError
  end

  it 'sets and merges valid entries' do
    data = Intercom::Lib::FlatStore.new
    data['a'] = 1
    data[:b] = 2
    _(data[:a]).must_equal 1
    _(data['b']).must_equal 2
    _(data[:b]).must_equal 2
    data = Intercom::Lib::FlatStore.new('a' => 1, :b => 2)
    _(data['a']).must_equal 1
    _(data[:a]).must_equal 1
    _(data['b']).must_equal 2
    _(data[:b]).must_equal 2
  end

  describe '#to_submittable_hash' do
    it 'filters out all hash values' do
      data = Intercom::Lib::FlatStore.new(
        'regular_attr' => 'value',
        'number_attr' => 42,
        'custom_object' => {
          'type' => 'Order.list',
          'instances' => [
            { 'id' => '31', 'external_id' => 'ext_123' }
          ]
        },
        'regular_hash' => { 'key' => 'value' },
        'metadata' => { 'source' => 'api', 'version' => 2 }
      )
      
      submittable = data.to_submittable_hash
      
      _(submittable['regular_attr']).must_equal 'value'
      _(submittable['number_attr']).must_equal 42
      
      _(submittable.key?('custom_object')).must_equal false
      _(submittable.key?('regular_hash')).must_equal false
      _(submittable.key?('metadata')).must_equal false
    end
  end
end
