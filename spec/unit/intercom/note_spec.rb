require "spec_helper"

describe "/v1/notes" do
  it "creates a note" do
    Intercom.expects(:post).with("/v1/users/notes", {:body => "Note to leave on user"}).returns({"html" => "<p>Note to leave on user</p>", "created_at" => 1234567890, "user" => test_user})
    note = Intercom::Note.create(:body => "Note to leave on user")
    note.html.must_equal "<p>Note to leave on user</p>"
    # note.user.name must_equal "Joe Schmoe"
  end
end