require "spec_helper"

describe Intercom::IncrementsStore do
  let(:data) { Intercom::IncrementsStore.new }

  it "must be an Intercom::FlatStore" do
    data.is_a?(Intercom::FlatStore).must_equal true
  end

  it "raises if you try to set a non numeric value" do
    proc { data["number_of_things"] = "non numeric value" }.must_raise ArgumentError
  end

  it "sets valid entry" do
    data["number_of_things"] = 1
    data[:number_of_things].must_equal 1
  end
end
