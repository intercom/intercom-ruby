module Intercom

  ##
  # Represents a note on a user
  #
  # A note contains a note (the text of the note you want to leave)
  #
  # == Examples
  #
  #  note = Intercom::Note.create(:email => "person@example.com", :body => "This is the note you want to make on the user account")

  # You can also create a note and save it like this:
  #  note = Intercom::Note.new
  #  note.body = "This is the note you want to make on the user account"
  #  note.save

  class Note < IntercomBaseObject

    ENDPOINT = "/v1/users/notes"
    REQUIRED_PARAMS = %W(body)

    attr_accessor :body
    attr_reader :html, :user
    attr_writer :user_id, :email

    def user
      Intercom::User.from_api(@user)
    end
  end
end