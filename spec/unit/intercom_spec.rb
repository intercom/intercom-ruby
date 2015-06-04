require "spec_helper"

describe Intercom do
  it "has a version number" do
    Intercom::VERSION.must_match(/\d+\.\d+\.\d+/)
  end
end
