require "spec_helper"

describe "/v1/notes" do
  it "creates a note" do
    Intercom.expects(:post).with("users/notes", {"note" => "Note to leave on user"}).returns({"note" => "Note to leave on user", "created_at" => 1234567890})
    note = Intercom::Note.create("note" => "Note to leave on user")
    note.note.must_equal "Note to leave on user"
  end

  it "sets/gets allowed keys" do
    params = {"note" => "Note body", "email" => "me@example.com", :user_id => "abc123"}
    note = Intercom::Note.new(params)
    note.to_hash.keys.sort.must_equal params.keys.map(&:to_s).sort
    params.keys.each do | key|
      note.send(key).must_equal params[key]
    end
  end
end