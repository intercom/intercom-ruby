# frozen_string_literal: true

require 'spec_helper'

describe Intercom do
  it 'has a version number' do
    _(Intercom::VERSION).must_match(/\d+\.\d+\.\d+/)
  end
end
