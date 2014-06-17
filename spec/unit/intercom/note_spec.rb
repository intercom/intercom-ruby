require "spec_helper"

describe "notes" do
  it "creates a note" do
    Intercom.expects(:post).with("/notes", {"body" => "Note to leave on user"}).returns({"body" => "<p>Note to leave on user</p>", "created_at" => 1234567890})
    note = Intercom::Note.create("body" => "Note to leave on user")
    note.body.must_equal "<p>Note to leave on user</p>"
  end

  it "sets/gets allowed keys" do
    params = {"body" => "Note body", "email" => "me@example.com", :user_id => "abc123"}
    note = Intercom::Note.new(params)

    note.to_hash.keys.sort.must_equal params.keys.map(&:to_s).sort
    params.keys.each do | key|
      note.send(key).must_equal params[key]
    end
  end
end
