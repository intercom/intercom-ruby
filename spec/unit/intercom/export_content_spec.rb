require 'spec_helper'

describe "Intercom::ExportContent" do
  let(:client) { Intercom::Client.new(token: 'token') }
  let(:job) {
    {
      job_identifier: "k0e27ohsyvh8ef3m",
      status: "no_data",
      download_url: "",
      download_expires_at: 0
    }
  }

  it "creates an export job" do
    client.expects(:post).with("/export/content/data", {"created_at_after" => 1667566801, "created_at_before" => 1668085202}).returns(job)
    client.export_content.create({"created_at_after" => 1667566801, "created_at_before" => 1668085202})
  end

  it "can view an export job" do
    client.expects(:get).with("/export/content/data/#{job[:job_identifier]}", {}).returns(job)
    client.export_content.find(id: job[:job_identifier])
  end

  it "Cancels a export job redirect" do
    client.expects(:post).with("/export/cancel/#{job[:job_identifier]}", {}).returns(job)
    client.export_content.cancel(job[:job_identifier])
  end
end
