require 'spec_helper'

describe "Intercom::Event" do

  let(:user) {Intercom::User.new("email" => "jim@example.com", :user_id => "12345", :created_at => Time.now, :name => "Jim Bob")}
  let(:created_time) {Time.now - 300}
  let (:client) { Intercom::Client.new(app_id: 'app_id',  api_key: 'api_key') }

  it "creates an event with metadata" do
    client.expects(:post).with('/events', {'event_name' => 'Eventful 1', 'created_at' => created_time.to_i, 'email' => 'joe@example.com', 'metadata' => {'invitee_email' => 'pi@example.org', :invite_code => 'ADDAFRIEND', 'found_date' => 12909364407}}).returns(:status => 202)

    client.events.create(:event_name => "Eventful 1", :created_at => created_time,
                                   :email => 'joe@example.com',
                                   :metadata => {
                                     "invitee_email" => "pi@example.org",
                                     :invite_code => "ADDAFRIEND",
                                     "found_date" => 12909364407
    })
  end

  it "creates an event without metadata" do
    client.expects(:post).with('/events', {'event_name' => 'sale of item', 'email' => 'joe@example.com'})
    client.events.create(:event_name => "sale of item", :email => 'joe@example.com')
  end

end
