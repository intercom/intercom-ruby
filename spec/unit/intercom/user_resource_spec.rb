require "spec_helper"

describe Intercom::UserResource do
  describe "requires_params" do
    it "raises if they are missing" do
      params = {"a" => 1, "b" => 2}
      Intercom::UserResource.requires_parameters(params, %W(a b))
      expected_message = "Missing required parameters (c)."
      proc { Intercom::UserResource.requires_parameters(params, %W(a b c)) }.must_raise ArgumentError, expected_message
      capture_exception { Intercom::UserResource.requires_parameters(params, %W(a b c)) }.message.must_equal expected_message
    end
  end
end