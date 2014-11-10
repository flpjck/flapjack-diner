require 'spec_helper'
require 'flapjack-diner'

describe Flapjack::Diner::Resources::Tags, :pact => true do

  before(:each) do
    Flapjack::Diner.base_uri('localhost:19081')
    Flapjack::Diner.logger = nil
  end

  context 'create' do

    it "submits a POST request for a tag" do
      flapjack.given("no tag exists").
        upon_receiving("a POST request with one tag").
        with(:method => :post, :path => '/tags',
             :headers => {'Content-Type' => 'application/vnd.api+json'},
             :body => {:tags => tag_data}).
        will_respond_with(
          :status => 201,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
          :body => {'tags' => tag_data} )

      result = Flapjack::Diner.create_tags(tag_data)
      expect(result).to eq(tag_data)
    end

    it "submits a POST request for several tags" do
      tags_data = [tag_data, tag_2_data]

      flapjack.given("no tag exists").
        upon_receiving("a POST request with two tags").
        with(:method => :post, :path => '/tags',
             :headers => {'Content-Type' => 'application/vnd.api+json'},
             :body => {:tags => tags_data}).
        will_respond_with(
          :status => 201,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
          :body => {'tags' => tags_data})

      result = Flapjack::Diner.create_tags(*tags_data)
      expect(result).to eq(tags_data)
    end

    # TODO fails to create with invalid data
  end

  context 'read' do

    context 'GET all tags' do

      it "has no data" do
        flapjack.given("no tag exists").
          upon_receiving("a GET request for all tags").
          with(:method => :get, :path => '/tags').
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
            :body => {:tags => []} )

        result = Flapjack::Diner.tags
        expect(result).to eq([])
      end

      it "has some data" do
        flapjack.given("a tag exists").
          upon_receiving("a GET request for all tags").
          with(:method => :get, :path => '/tags').
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
            :body => {:tags => [tag_data]} )

        result = Flapjack::Diner.tags
        expect(result).to eq([tag_data])
      end

    end

    context 'GET a single tag' do

      it "has some data" do
        flapjack.given("a tag exists").
          upon_receiving("a GET request for tag 'www.example.com:SSH'").
          with(:method => :get, :path => "/tags/#{tag_data[:id]}").
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
            :body => {:tags => [tag_data]} )

        result = Flapjack::Diner.tags(tag_data[:id])
        expect(result).to eq([tag_data])
      end

      it "can't find tag" do
        flapjack.given("no tag exists").
          upon_receiving("a GET request for tag 'www.example.com:SSH'").
          with(:method => :get, :path => "/tags/#{tag_data[:id]}").
          will_respond_with(
            :status => 404,
            :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
            :body => {:errors => ["could not find Tag records, ids: '#{tag_data[:id]}'"]} )

        result = Flapjack::Diner.tags(tag_data[:id])
        expect(result).to be_nil
        expect(Flapjack::Diner.last_error).to eq(:status_code => 404,
          :errors => ["could not find Tag records, ids: '#{tag_data[:id]}'"])
      end

    end

  end

  context 'update' do

    it 'submits a PUT request for a tag' do
      flapjack.given("a tag exists").
        upon_receiving("a PUT request for a single tag").
        with(:method => :put,
             :path => "/tags/#{tag_data[:id]}",
             :body => {:tags => {:id => tag_data[:id], :name => 'alphabet'}},
             :headers => {'Content-Type' => 'application/vnd.api+json'}).
        will_respond_with(
          :status => 204,
          :body => '' )

      result = Flapjack::Diner.update_tags(:id => tag_data[:id], :name => 'alphabet')
      expect(result).to be_a(TrueClass)
    end

    it 'submits a PUT request for several tags' do
      flapjack.given("two tags exist").
        upon_receiving("a PUT request for two tags").
        with(:method => :put,
             :path => "/tags/#{tag_data[:id]},#{tag_2_data[:id]}",
             :body => {:tags => [{:id => tag_data[:id], :name => 'alphabet'},
                                 {:id => tag_2_data[:id], :name => 'numeral'}
                                ]
                      },
             :headers => {'Content-Type' => 'application/vnd.api+json'}).
        will_respond_with(
          :status => 204,
          :body => '' )

      result = Flapjack::Diner.update_tags(
        {:id => tag_data[:id], :name => 'alphabet'},
        {:id => tag_2_data[:id], :name => 'numeral'})
      expect(result).to be_a(TrueClass)
    end

    it "can't find the tag to update" do
      flapjack.given("no tag exists").
        upon_receiving("a PUT request for a single tag").
        with(:method => :put,
             :path => "/tags/#{tag_data[:id]}",
             :body => {:tags => {:id => tag_data[:id], :name => 'alphabet'}},
             :headers => {'Content-Type' => 'application/vnd.api+json'}).
        will_respond_with(
          :status => 404,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
          :body => {:errors => ["could not find Tag records, ids: '#{tag_data[:id]}'"]} )

      result = Flapjack::Diner.update_tags(:id => tag_data[:id], :name => 'alphabet')
      expect(result).to be_nil
      expect(Flapjack::Diner.last_error).to eq(:status_code => 404,
        :errors => ["could not find Tag records, ids: '#{tag_data[:id]}'"])
    end

  end

  context 'delete' do
    it "submits a DELETE request for a tag" do
      flapjack.given("a tag exists").
        upon_receiving("a DELETE request for a single tag").
        with(:method => :delete,
             :path => "/tags/#{tag_data[:id]}",
             :body => nil).
        will_respond_with(:status => 204,
                          :body => '')

      result = Flapjack::Diner.delete_tags(tag_data[:id])
      expect(result).to be_a(TrueClass)
    end

    it "submits a DELETE request for several tags" do
      flapjack.given("two tags exist").
        upon_receiving("a DELETE request for two tags").
        with(:method => :delete,
             :path => "/tags/#{tag_data[:id]},#{tag_2_data[:id]}",
             :body => nil).
        will_respond_with(:status => 204,
                          :body => '')

      result = Flapjack::Diner.delete_tags(tag_data[:id], tag_2_data[:id])
      expect(result).to be_a(TrueClass)
    end

    it "can't find the tag to delete" do
      flapjack.given("no tag exists").
        upon_receiving("a DELETE request for a single tag").
        with(:method => :delete,
             :path => "/tags/#{tag_data[:id]}",
             :body => nil).
        will_respond_with(
          :status => 404,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
          :body => {:errors => ["could not find Tag records, ids: '#{tag_data[:id]}'"]}
        )

      result = Flapjack::Diner.delete_tags(tag_data[:id])
      expect(result).to be_nil
      expect(Flapjack::Diner.last_error).to eq(:status_code => 404,
        :errors => ["could not find Tag records, ids: '#{tag_data[:id]}'"])

    end
  end

end
