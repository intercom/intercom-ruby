require "spec_helper"

describe "tours" do
  let (:client) { Intercom::Client.new(app_id: 'app_id',  api_key: 'api_key') }
  let(:response) {
    {
      "type" => "tour.list",
      "tours" => [
        {
          "id" => "1234",
          "type" => "tour",
          "title" => "Sample tour",
        }
      ]
    }
  }
  it "lists the tours" do
    client.expects(:get).with("/tours", {}).returns(response)
    tour = client.tours.all.first
    expect(tour.id).must_equal "1234"
    expect(tour.title).must_equal "Sample tour"
  end

end
