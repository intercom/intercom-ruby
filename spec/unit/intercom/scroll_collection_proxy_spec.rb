# frozen_string_literal: true

require 'spec_helper'

describe Intercom::ScrollCollectionProxy do
  let(:client) { Intercom::Client.new(token: 'token') }

  it 'stops iterating if no companies returned' do
    client.expects(:get).with('/companies/scroll', '').returns(companies_scroll(false))
    names = []
    client.companies.scroll.each { |company| names << company.name }
    _(names).must_equal %w[]
  end

  it 'keeps iterating if companies returned' do
    client.expects(:get).with('/companies/scroll', '').returns(companies_scroll(true))
    client.expects(:get).with('/companies/scroll', scroll_param: 'da6bbbac-25f6-4f07-866b-b911082d7').returns(companies_scroll(false))
    names = []
    client.companies.scroll.each { |company| names << company.name }
  end

  it 'supports indexed array access' do
    client.expects(:get).with('/companies/scroll', '').returns(companies_scroll(true))
    _(client.companies.scroll[0].name).must_equal 'company1'
  end

  it 'supports map' do
    client.expects(:get).with('/companies/scroll', '').returns(companies_scroll(true))
    client.expects(:get).with('/companies/scroll', scroll_param: 'da6bbbac-25f6-4f07-866b-b911082d7').returns(companies_scroll(false))
    names = client.companies.scroll.map(&:name)
    _(names).must_equal %w[company1 company2 company3]
  end

  it 'returns one page scroll' do
    client.expects(:get).with('/companies/scroll', '').returns(companies_scroll(true))
    scroll = client.companies.scroll.next
    names = []
    scroll.records.each { |usr| names << usr.name }
    _(names).must_equal %w[company1 company2 company3]
  end

  it 'keeps iterating if called with scroll_param' do
    client.expects(:get).with('/companies/scroll', '').returns(companies_scroll(true))
    client.expects(:get).with('/companies/scroll', scroll_param: 'da6bbbac-25f6-4f07-866b-b911082d7').returns(companies_scroll(true))
    scroll = client.companies.scroll.next
    scroll = client.companies.scroll.next('da6bbbac-25f6-4f07-866b-b911082d7')
    scroll.records.each(&:name)
  end

  it 'works with an empty list' do
    client.expects(:get).with('/companies/scroll', '').returns(companies_scroll(false))
    scroll = client.companies.scroll.next
    names = []
    scroll.records.each { |usr| names << usr.name }
    _(names).must_equal %w[]
  end
end
