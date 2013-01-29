require 'intercom/user_resource'

module Intercom

  ##
  # Represents a note on a user
  #
  # A note contains a note (the text of the note you want to leave)
  #
  # == Examples
  #
  #  note = Intercom::Note.create(:email => "person@example.com", :note => "This is the note you want to make on the user account")

  # You can also create a note and save it like this:
  #  note = Intercom::Note.new
  #  note.note = "This is the note you want to make on the user account"
  #  note.save

  class Note < UserResource
    ##
    # Creates a new Note using params and saves it
    # @see #save
    def self.create(params)
      requires_parameters(params, %W(note))
      Note.new(params).save
    end

    ##
    # Records a note on a user of your application
    def save
      response = Intercom.post("users/notes", to_hash)
      self.update_from_api_response(response)
    end

    ##
    # Set the text of the note for the user
    def note=(note)
      @attributes["note"] = note
    end

  end
end