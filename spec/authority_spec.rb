require 'net/http'
require File.dirname(__FILE__) + '/spec_helper'

class SDSSpec < Test::Unit::TestCase
  context "A service instance" do
    setup do
      @service = SDSRest::Service.new
      @service.authority = nil
    end

    should "respond to :create_authority" do
      assert_respond_to @service, :create_authority
    end

    should "be able to create an authority" do
      results = @service.create_authority random
      assert_instance_of Net::HTTPCreated, results
    end

    should "respond to :get_authority" do
      assert_respond_to @service, :get_authority
    end

    should "be able to get an authority" do
      authority_name = random

      @service.create_authority authority_name

      results = @service.get_authority authority_name
      assert_instance_of Net::HTTPOK, results
    end

  end

end