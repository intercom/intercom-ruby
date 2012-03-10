require "spec_helper"

describe Intercom::UserCustomData do
  it "raises if you try to set or merge in nested hash structures" do
    data = Intercom::UserCustomData.new()
    proc { data["thing"] = [1] }.must_raise ArgumentError
    proc { data["thing"] = {1 => 2} }.must_raise ArgumentError
    proc { Intercom::UserCustomData.new({1 => {2 => 3}}) }.must_raise ArgumentError
  end

  it "raises if you try to use a non string key" do
    data = Intercom::UserCustomData.new()
    proc { data[1] = "something" }.must_raise ArgumentError
  end

  it "sets and merges valid entries" do
    data = Intercom::UserCustomData.new()
    data["a"] = 1
    data[:b] = 2
    data[:a].must_equal 1
    data["b"].must_equal 2
    data[:b].must_equal 2
    data = Intercom::UserCustomData.new({"a" => 1, :b => 2})
    data["a"].must_equal 1
    data[:a].must_equal 1
    data["b"].must_equal 2
    data[:b].must_equal 2
  end
end