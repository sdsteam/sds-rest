require 'net/http'
require File.dirname(__FILE__) + '/spec_helper'

class SSDSSpec < Test::Unit::TestCase
  context "A service instance" do
    setup do
      @service = SDSRest::Service.new
    end
    
    should "respond to :create_container" do
      assert_respond_to @service, :create_container
    end
    
    should "be able to create a container" do
      results = @service.create_container random
      assert_instance_of Net::HTTPCreated, results
    end
    
    should "respond to :delete_container" do
      assert_respond_to @service, :delete_container
    end
    
    should "be able to delete a container" do
      container_name = random
      
      @service.create_container container_name
      
      results = @service.delete_container container_name
      assert_instance_of Net::HTTPOK, results    
    end
    
    should "respond to :get_container" do
      assert_respond_to @service, :get_container
    end
    
    should "be able to get a container" do
      container_name = random
      
      @service.create_container container_name
      
      results = @service.get_container container_name
      assert_instance_of Net::HTTPOK, results
    end
    
  end
end