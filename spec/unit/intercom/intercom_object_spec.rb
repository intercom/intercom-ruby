require "spec_helper"

describe "Intercom::IntercomObject" do
  describe "requires_params" do
    it "raises if they are missing" do
      params = {"a" => 1, "b" => 2}
      Intercom::IntercomObject.requires_parameters(params, %W(a b))
      expected_message = "Missing required parameters (c)."
      proc { Intercom::IntercomObject.requires_parameters(params, %W(a b c)) }.must_raise ArgumentError, expected_message
      capture_exception { Intercom::IntercomObject.requires_parameters(params, %W(a b c)) }.message.must_equal expected_message
    end
  end

  describe "allows_params" do
    it "raises if there are extra ones" do
      params = {"a" => 1, "b" => 2}
      Intercom::IntercomObject.allows_parameters(params, %W(a b))
      expected_message = "Unexpected parameters (b). Only allowed parameters for this operation are (email, user_id, a)."
      proc { Intercom::IntercomObject.allows_parameters(params, %W(a)) }.must_raise ArgumentError, expected_message
      capture_exception { Intercom::IntercomObject.allows_parameters(params, %W(a)) }.message.must_equal expected_message
    end

    it "it ignores email and user_id since they are always allowed" do
      params = {"a" => 1, "b" => 2, "email" => "ddd@ddd.ddd", "user_id" => "123abc"}
      Intercom::IntercomObject.allows_parameters(params, %W(a b))
      Intercom::IntercomObject.allows_parameters(params, %W(a b email user_id))
    end
  end
end