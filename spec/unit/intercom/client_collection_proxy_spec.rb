require "spec_helper"

describe Intercom::ClientCollectionProxy do
  let(:client) { Intercom::Client.new(token: 'token') }

  it "stops iterating if no next link" do
    client.expects(:get).with("/companies", {}).returns(page_of_companies(false))
    names = []
    client.companies.all.each { |company| names << company.name }
    _(names).must_equal %W(company1 company2 company3)
  end

  it "keeps iterating if next link" do
    client.expects(:get).with("/companies", {}).returns(page_of_companies(true))
    client.expects(:get).with('https://api.intercom.io/companies?per_page=50&page=2', {}).returns(page_of_companies(false))
    names = []
    client.companies.all.each { |company| names << company.name }
  end

  it "supports indexed array access" do
    client.expects(:get).with("/companies", {}).returns(page_of_companies(false))
    _(client.companies.all[0].name).must_equal 'company1'
  end

  it "supports map" do
    client.expects(:get).with("/companies", {}).returns(page_of_companies(false))
    names = client.companies.all.map { |company| company.name }
    _(names).must_equal %W(company1 company2 company3)
  end

  it "supports querying" do
    client.expects(:get).with("/companies", {:tag_name => 'Taggart J'}).returns(page_of_companies(false))
    _(client.companies.find_all(:tag_name => 'Taggart J').map(&:name)).must_equal %W(company1 company2 company3)
  end

  it "supports single page pagination" do
    companies = [test_company("company1"), test_company("company2"), test_company("company3"),
     test_company("company4"), test_company("company5"), test_company("company6"),
     test_company("company7"), test_company("company8"), test_company("company9"),
     test_company("company10")]
    client.expects(:get).with("/companies", {:type=>'companies', :per_page => 10, :page => 1}).returns(companies_pagination(include_next_link: false, per_page: 10, page: 1, total_pages: 1, total_count: 10, company_list: companies))
    result = client.companies.find_all(:type=>'companies', :per_page => 10, :page => 1).map {|company| company.name }
    _(result).must_equal %W(company1 company2 company3 company4 company5 company6 company7 company8 company9 company10)
  end

  it "supports multi page pagination" do
    companies = [test_company("company3"), test_company("company4")]
    client.expects(:get).with("/companies", {:type=>'companies', :per_page => 2, :page => 3}).returns(companies_pagination(include_next_link: true, per_page: 2, page: 3, total_pages: 5, total_count: 10, company_list: companies))
    result = client.companies.find_all(:type=>'companies', :per_page => 2, :page => 3).map {|company| company.name }
    _(result).must_equal %W(company3 company4)
  end

  it "works with page out of range request" do
    companies = []
    client.expects(:get).with("/companies", {:type=>'companies', :per_page => 2, :page => 30}).returns(companies_pagination(include_next_link: true, per_page: 2, page: 30, total_pages: 2, total_count: 3, company_list: companies))
    result = client.companies.find_all(:type=>'companies', :per_page => 2, :page => 30).map {|company| company.name }
    _(result).must_equal %W()
  end

  it "works with asc order" do
    test_date=1457337600
    time_increment=1000
    companies = [test_company_dates(name="company1", created_at=test_date), test_company_dates(name="company2", created_at=test_date-time_increment),
             test_company_dates(name="company3", created_at=test_date-2*time_increment), test_company_dates(name="company4", created_at=test_date-3*time_increment)]
    client.expects(:get).with("/companies", {:type=>'companies', :per_page => 4, :page => 5, :order => "asc", :sort => "created_at"}).returns(companies_pagination(include_next_link: true, per_page: 4, page: 5, total_pages: 6, total_count: 30, company_list: companies))
    result = client.companies.find_all(:type=>'companies', :per_page => 4, :page => 5, :order => "asc", :sort => "created_at").map(&:name)
    _(result).must_equal %W(company1 company2 company3 company4)
  end

  it "works with desc order" do
    test_date=1457337600
    time_increment=1000
    companies = [test_company_dates(name="company4", created_at=3*test_date), test_company_dates(name="company3", created_at=test_date-2*time_increment),
             test_company_dates(name="company2", created_at=test_date-time_increment), test_company_dates(name="company1", created_at=test_date)]
    client.expects(:get).with("/companies", {:type=>'companies', :per_page => 4, :page => 5, :order => "desc", :sort => "created_at"}).returns(companies_pagination(include_next_link: true, per_page: 4, page: 5, total_pages: 6, total_count: 30, company_list: companies))
    result = client.companies.find_all(:type=>'companies', :per_page => 4, :page => 5, :order => "desc", :sort => "created_at").map {|company| company.name }
    _(result).must_equal %W(company4 company3 company2 company1)
  end

end
