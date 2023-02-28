# frozen_string_literal: true

require 'spec_helper'

describe Intercom::Lib::FlatStore do
  it 'raises if you try to set or merge in nested hash structures' do
    data = Intercom::Lib::FlatStore.new
    _(proc { data['thing'] = { 1 => 2 } }).must_raise ArgumentError
    _(proc { Intercom::Lib::FlatStore.new(1 => { 2 => 3 }) }).must_raise ArgumentError
  end

  it 'raises if you try to use a non string key' do
    data = Intercom::Lib::FlatStore.new
    _(proc { data[1] = 'something' }).must_raise ArgumentError
  end

  it 'sets and merges valid entries' do
    data = Intercom::Lib::FlatStore.new
    data['a'] = 1
    data[:b] = 2
    data['array'] = [1]
    data[:another_array] = [2]
    _(data[:a]).must_equal 1
    _(data['b']).must_equal 2
    _(data[:b]).must_equal 2
    _(data[:array]).must_equal [1]
    _(data['another_array']).must_equal [2]
    data = Intercom::Lib::FlatStore.new('a' => 1, :b => 2)
    _(data['a']).must_equal 1
    _(data[:a]).must_equal 1
    _(data['b']).must_equal 2
    _(data[:b]).must_equal 2
    _(data[:array]).must_equal [1]
    _(data['array']).must_equal [1]
    _(data[:another_array]).must_equal [2]
    _(data['another_array']).must_equal [2]
  end
end
