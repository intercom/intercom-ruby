require "spec_helper"

describe "jobs" do
  let(:client) { Intercom::Client.new(token: 'token') }
  let (:job) {
    {
      "app_id" => "app_id",
      "id" => "super_awesome_job",
      "created_at" => 1446033421,
      "completed_at" => 1446048736,
      "closing_at" => 1446034321,
      "updated_at" => 1446048736,
      "name" => "api_bulk_job",
      "state" => "completed",
      "links" =>
        {
          "error" => "https://api.intercom.io/jobs/super_awesome_job/error",
          "self" => "https://api.intercom.io/jobs/super_awesome_job"
        },
      "tasks" =>
        [
          {
            "id" => "super_awesome_task",
            "item_count" => 2,
            "created_at" => 1446033421,
            "started_at" => 1446033709,
            "completed_at" => 1446033709,
            "state" => "completed"
          }
        ]
    }
  }
  let (:error_feed) {
    {
      "app_id" => "app_id",
      "job_id" => "super_awesome_job",
      "pages" => {},
      "items" => []
    }
  }

  it 'gets a job' do
    client.expects(:get).with("/jobs/super_awesome_job", {}).returns(job)
    client.jobs.find(id: 'super_awesome_job')
  end

  it 'gets a job\'s error feed' do
    client.expects(:get).with("/jobs/super_awesome_job/error", {}).returns(error_feed)
    client.jobs.errors(id: 'super_awesome_job')
  end
end
