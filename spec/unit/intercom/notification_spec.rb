require 'spec_helper'

describe "Intercom::Notification" do
  let (:client) { Intercom::Client.new(app_id: 'app_id',  api_key: 'api_key') }

  it "loads notification correctly" do
    payload = client.notifications.load(test_notification_hash)
    payload.must_be_kind_of Intercom::Notification
    expect(payload.model_type).must_equal "company"
    company = payload.load
    company.must_be_kind_of Intercom::Company
    company.name.must_equal("Blue Sun")
  end

  def test_notification_hash
    {
      "type" => "notification_event",
      "topic" => "company.created",
      "id" => "notif_ccd8a4d0-f965-11e3-a367-c779cae3e1b3",
      "created_at" => 1392731331,
      "delivery_attempts" => 1,
      "first_sent_at" => 1392731392,
      "data" => {
        "item" => {
          "type" => "company",
          "id" => "531ee472cce572a6ec000006",
          "name" => "Blue Sun",
          "company_id" => "6",
          "remote_created_at" => 1394531169,
          "created_at" => 1394533506,
          "updated_at" => 1396874658,
          "custom_attributes" => {
          }
        }
      }
    }
  end

end
