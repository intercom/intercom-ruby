require 'spec_helper'

describe "Intercom::Article" do
  let(:client) { Intercom::Client.new(token: 'token') }

  describe "Getting an Article" do
    it "successfully finds an article" do
      client.expects(:get).with("/articles/1", {}).returns(test_article)
      client.articles.find(id: "1")
    end

    it "successfully finds an article with translations" do
      client.expects(:get).with("/articles/1", {}).returns(test_article_with_translations)
      client.articles.find(id: "1")
    end
  end

  describe "Listing Articles" do
    it "successfully finds all articles" do
      client.expects(:get).with("/articles", {}).returns(test_article_list)
      client.articles.all.to_a
    end
  end

  describe "Creating an Article" do
    it "successfully creates and article with information passed individually" do
      client.expects(:post).with("/articles", {"title" => "new title", "author_id" => 1, "body" => "<p>thingbop</p>", "state" => "draft"}).returns(test_article)
      client.articles.create(:title => "new title", :author_id => 1, :body => "<p>thingbop</p>", :state => "draft")
    end

    it "successfully creates and article with information in json" do
      client.expects(:post).with("/articles", {"title" => "new title", "author_id" => 1, "body" => "<p>thingbop</p>", "state" => "draft"}).returns(test_article)
      client.articles.create({title: "new title", author_id: 1, body: "<p>thingbop</p>", state: "draft"})
    end
  end

  describe "Updating an article" do
    it "successfully updates an article" do
      article = Intercom::Article.new(id: 12345)
      client.expects(:put).with('/articles/12345', {})
      client.articles.save(article)
    end
  end

  describe "Deleting an article" do
    it "successfully deletes an article" do
      article = Intercom::Article.new(id: 12345)
      client.expects(:delete).with('/articles/12345', {})
      client.articles.delete(article)
    end
  end
end
