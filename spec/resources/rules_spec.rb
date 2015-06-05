require 'spec_helper'
require 'flapjack-diner'

describe Flapjack::Diner::Resources::Rules, :pact => true do

  before(:each) do
    Flapjack::Diner.base_uri('localhost:19081')
    Flapjack::Diner.logger = nil
  end

  context 'create' do

    it "submits a POST request for a rule" do
      req_data  = rule_json(rule_data)
      resp_data = req_data.merge(:relationships => rule_rel(rule_data))

      flapjack.given("no data exists").
        upon_receiving("a POST request with one rule").
        with(:method => :post, :path => '/rules',
             :headers => {'Content-Type' => 'application/vnd.api+json'},
             :body => {:data => req_data}).
        will_respond_with(
          :status => 201,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
         :body => {:data => resp_data}
        )

      result = Flapjack::Diner.create_rules(rule_data)
      expect(result).not_to be_nil
      expect(result).to eq(resultify(resp_data))
    end

    it "submits a POST request for several rules" do
      req_data = [rule_json(rule_data), rule_json(rule_2_data)]
      resp_data = [
        req_data[0].merge(:relationships => rule_rel(rule_data)),
        req_data[1].merge(:relationships => rule_rel(rule_2_data))
      ]

      flapjack.given("no data exists").
        upon_receiving("a POST request with two rules").
        with(:method => :post, :path => '/rules',
             :headers => {'Content-Type' => 'application/vnd.api+json; ext=bulk'},
             :body => {:data => req_data}).
        will_respond_with(
          :status => 201,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
          :body => {:data => resp_data}
        )

      result = Flapjack::Diner.create_rules(rule_data, rule_2_data)
      expect(result).not_to be_nil
      expect(result).to eq(resultify(resp_data))
    end

    # TODO error due to invalid data

  end

  context 'read' do

    it "submits a GET request for all rules" do
      resp_data = [rule_json(rule_data).merge(:relationships => rule_rel(rule_data))]

      flapjack.given("a rule exists").
        upon_receiving("a GET request for all rules").
        with(:method => :get, :path => '/rules').
        will_respond_with(
          :status => 200,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
            :body => {:data => resp_data} )

      result = Flapjack::Diner.rules
      expect(result).not_to be_nil
      expect(result).to eq(resultify(resp_data))
    end

    it "submits a GET request for one rule" do
      resp_data = rule_json(rule_data).merge(:relationships => rule_rel(rule_data))

      flapjack.given("a rule exists").
        upon_receiving("a GET request for a single rule").
        with(:method => :get, :path => "/rules/#{rule_data[:id]}").
        will_respond_with(
          :status => 200,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
            :body => {:data => resp_data}
        )

      result = Flapjack::Diner.rules(rule_data[:id])
      expect(result).not_to be_nil
      expect(result).to eq(resultify(resp_data))
    end

    it "submits a GET request for several rules" do
      resp_data = [
        rule_json(rule_data).merge(:relationships => rule_rel(rule_data)),
        rule_json(rule_2_data).merge(:relationships => rule_rel(rule_2_data))
      ]

      rules_data = [rule_data.merge(:type => 'rule'), rule_2_data.merge(:type => 'rule')]

      flapjack.given("two rules exist").
        upon_receiving("a GET request for two rules").
        with(:method => :get, :path => "/rules",
             :query => "filter%5B%5D=id%3A#{rule_data[:id]}%7C#{rule_2_data[:id]}").
        will_respond_with(
          :status => 200,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
            :body => {:data => resp_data} )

      result = Flapjack::Diner.rules(rule_data[:id], rule_2_data[:id])
      expect(result).not_to be_nil
      expect(result).to eq(resultify(resp_data))
    end

    it "can't find the rule to read" do
      flapjack.given("no data exists").
        upon_receiving("a GET request for a single rule").
        with(:method => :get, :path => "/rules/#{rule_data[:id]}").
        will_respond_with(
          :status => 404,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
          :body => {:errors => [{
              :status => '404',
              :detail => "could not find Rule record, id: '#{rule_data[:id]}'"
            }]}
          )

      result = Flapjack::Diner.rules(rule_data[:id])
      expect(result).to be_nil
      expect(Flapjack::Diner.last_error).to eq([{:status => '404',
        :detail => "could not find Rule record, id: '#{rule_data[:id]}'"}])
    end

  end

  # # Not immediately relevant, no data fields to update until time_restrictions are fixed
  # context 'update' do
  #   it 'submits a PUT request for a rule' do
  #     flapjack.given("a rule exists").
  #       upon_receiving("a PUT request for a single rule").
  #       with(:method => :put,
  #            :path => "/rules/#{rule_data[:id]}",
  #            :body => {:rules => {:id => rule_data[:id], :time_restrictions => []}},
  #            :headers => {'Content-Type' => 'application/vnd.api+json'}).
  #       will_respond_with(
  #         :status => 204,
  #         :body => '' )

  #     result = Flapjack::Diner.update_rules(:id => rule_data[:id], :time_restrictions => [])
  #     expect(result).to be_a(TrueClass)
  #   end

  #   it 'submits a PUT request for several rules' do
  #     flapjack.given("two rules exist").
  #       upon_receiving("a PUT request for two rules").
  #       with(:method => :put,
  #            :path => "/rules/#{rule_data[:id]},#{rule_2_data[:id]}",
  #            :body => {:rules => [{:id => rule_data[:id], :time_restrictions => []},
  #            {:id => rule_2_data[:id], :enabled => true}]},
  #            :headers => {'Content-Type' => 'application/vnd.api+json'}).
  #       will_respond_with(
  #         :status => 204,
  #         :body => '' )

  #     result = Flapjack::Diner.update_rules(
  #       {:id => rule_data[:id], :time_restrictions => []},
  #       {:id => rule_2_data[:id], :enabled => true})
  #     expect(result).to be_a(TrueClass)
  #   end

  #   it "can't find the rule to update" do
  #     flapjack.given("no data exists").
  #       upon_receiving("a PUT request for a single rule").
  #       with(:method => :put,
  #            :path => "/rules/#{rule_data[:id]}",
  #            :body => {:rules => {:id => rule_data[:id], :time_restrictions => []}},
  #            :headers => {'Content-Type' => 'application/vnd.api+json'}).
  #       will_respond_with(
  #         :status => 404,
  #         :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
  #         :body => {:errors => [{
  #             :status => '404',
  #             :detail => "could not find Rule records, ids: '#{rule_data[:id]}'"
  #           }]}
  #         )

  #     result = Flapjack::Diner.update_rules(:id => rule_data[:id], :time_restrictions => [])
  #     expect(result).to be_nil
  #     expect(Flapjack::Diner.last_error).to eq([{:status => '404',
  #       :detail => "could not find Rule records, ids: '#{rule_data[:id]}'"}])
  #   end
  # end

  context 'delete' do

    it "submits a DELETE request for a rule" do
      flapjack.given("a rule exists").
        upon_receiving("a DELETE request for a single rule").
        with(:method => :delete,
             :path => "/rules/#{rule_data[:id]}",
             :body => nil).
        will_respond_with(:status => 204,
                          :body => '')

      result = Flapjack::Diner.delete_rules(rule_data[:id])
      expect(result).to be_a(TrueClass)
    end

    it "submits a DELETE request for several rules" do
      rules_data = [{:type => 'rule', :id => rule_data[:id]},
                    {:type => 'rule', :id => rule_2_data[:id]}]

      flapjack.given("two rules exist").
        upon_receiving("a DELETE request for two rules").
        with(:method => :delete,
             :headers => {'Content-Type' => 'application/vnd.api+json; ext=bulk'},
             :path => "/rules",
             :body => {:data => rules_data}).
        will_respond_with(:status => 204,
                          :body => '')

      result = Flapjack::Diner.delete_rules(rule_data[:id], rule_2_data[:id])
      expect(result).to be_a(TrueClass)
    end

    it "can't find the rule to delete" do
      flapjack.given("no data exists").
        upon_receiving("a DELETE request for a single rule").
        with(:method => :delete,
             :path => "/rules/#{rule_data[:id]}",
             :body => nil).
        will_respond_with(
          :status => 404,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
          :body => {:errors => [{
              :status => '404',
              :detail => "could not find Rule record, id: '#{rule_data[:id]}'"
            }]}
          )

      result = Flapjack::Diner.delete_rules(rule_data[:id])
      expect(result).to be_nil
      expect(Flapjack::Diner.last_error).to eq([{:status => '404',
        :detail => "could not find Rule record, id: '#{rule_data[:id]}'"}])
    end
  end

end
