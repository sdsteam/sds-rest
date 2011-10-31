require 'net/http'
require File.dirname(__FILE__) + '/spec_helper'

class SSDSSpec < Test::Unit::TestCase
  context "A service instance" do
    setup do
      @service = SDSRest::Service.new
      @container = random
      @service.create_container @container
    end

    should "respond to :create_blob" do
      assert_respond_to @service, :create_blob
    end

    should "be able to create a blob" do
      results = @service.create_blob @container, "test-text", 1
      assert_instance_of Net::HTTPCreated, results
    end

    should "respond to :get_blob" do
      assert_respond_to @service, :get_blob
    end

    should "be able to get a blob" do
      @service.create_blob @container, "test-text", 1
      results = @service.get_blob @container, 1
      assert_instance_of Net::HTTPOK, results
    end

    should "respond to :update_blob" do
      assert_respond_to @service, :update_blob
    end

    should "be able to update a blob" do
      @service.create_blob @container, "test-text", 1
      results = @service.update_blob @container, "test-text2", 1
      assert_instance_of Net::HTTPOK, results
    end

    should "respond to :delete_blob" do
      assert_respond_to @service, :delete_blob
    end

    should "be able to delete a blob" do
      @service.create_blob @container, "test-text", 1
      results = @service.delete_blob @container, 1
      assert_instance_of Net::HTTPOK, results
    end

  end

end