require 'spec_helper'

describe "Intercom::Event" do

  let(:user) {Intercom::User.new("email" => "jim@example.com", :user_id => "12345", :created_at => Time.now, :name => "Jim Bob")}
  let(:created_time) {Time.now - 300}
  let(:client) { Intercom::Client.new(token: 'token') }

  it 'gets events for a user' do
    client.expects(:get).with('/events', type: 'user', email: 'joe@example.com').returns(test_event_list)
    client.events.find_all(type: 'user', email: 'joe@example.com').first
  end

  it "has the correct collection proxy class" do
    _(client.events.collection_proxy_class).must_equal Intercom::EventCollectionProxy
  end

  it "stops iterating if no next link" do
    client.expects(:get).with("/events", type: 'user', email: 'joe@example.com').returns(page_of_events(false))
    event_names = []
    client.events.find_all(type: 'user', email: 'joe@example.com').each { |event| event_names << event.event_name }
    _(event_names).must_equal %W(invited-friend)
  end

  it "keeps iterating if next link" do
    client.expects(:get).with("/events", type: 'user', email: 'joe@example.com').returns(page_of_events(true))
    client.expects(:get).with("https://api.intercom.io/events?type=user&intercom_user_id=55a3b&before=144474756550", {}).returns(page_of_events(false))
    event_names = []
    client.events.find_all(type: 'user', email: 'joe@example.com').each { |event| event_names << event.event_name }
    _(event_names).must_equal %W(invited-friend invited-friend)
  end

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
    client.expects(:post).with('/events', {'event_name' => 'sale of item', 'id' => 123})
    client.events.create(:event_name => "sale of item", :id => 123)
  end

  describe 'bulk operations' do
    let (:job) {
      {
        "app_id"=>"app_id",
        "id"=>"super_awesome_job",
        "created_at"=>1446033421,
        "completed_at"=>1446048736,
        "closing_at"=>1446034321,
        "updated_at"=>1446048736,
        "name"=>"api_bulk_job",
        "state"=>"completed",
        "links"=>
          {
            "error"=>"https://api.intercom.io/jobs/super_awesome_job/error",
            "self"=>"https://api.intercom.io/jobs/super_awesome_job"
          },
        "tasks"=>
          [
            {
              "id"=>"super_awesome_task",
              "item_count"=>2,
              "created_at"=>1446033421,
              "started_at"=>1446033709,
              "completed_at"=>1446033709,
              "state"=>"completed"
            }
          ]
      }
    }
    let(:bulk_request) {
      {
        items: [
          {
            method: "post",
            data_type: "event",
            data: {
              event_name: "ordered-item",
              created_at: 1438944980,
              user_id: "314159",
              metadata: {
                order_date: 1438944980,
                stripe_invoice: "inv_3434343434"
              }
            }
          },
          {
            method: "post",
            data_type: "event",
            data: {
              event_name: "invited-friend",
              created_at: 1438944979,
              user_id: "314159",
              metadata: {
                invitee_email: "pi@example.org",
                invite_code: "ADDAFRIEND"
              }
            }
          }
        ]
      }
    }
    let(:events) {
      [
        {
          event_name: "ordered-item",
          created_at: 1438944980,
          user_id: "314159",
          metadata: {
            order_date: 1438944980,
            stripe_invoice: "inv_3434343434"
          }
        },
        {
          event_name: "invited-friend",
          created_at: 1438944979,
          user_id: "314159",
          metadata: {
            invitee_email: "pi@example.org",
            invite_code: "ADDAFRIEND"
          }
        }
      ]
    }

    it "submits a bulk job" do
      client.expects(:post).with("/bulk/events", bulk_request).returns(job)
      client.events.submit_bulk_job(create_items: events)
    end

    it "adds events to an existing bulk job" do
      bulk_request[:job] = {id: 'super_awesome_job'}
      client.expects(:post).with("/bulk/events", bulk_request).returns(job)
      client.events.submit_bulk_job(create_items: events, job_id: 'super_awesome_job')
    end

    it "does not submit delete jobs" do
      _(lambda { client.events.submit_bulk_job(delete_items: events) }).must_raise ArgumentError
    end
  end
end
