require 'net/http'

require File.dirname(__FILE__) + '/spec_helper'

class SDSSpec < Test::Unit::TestCase
  context "An SDSActiveResource class" do
    setup do
      @service = SDSRest::Service.new
      @container = random
      @service.create_container @container
      @connection = SDSActiveResource::SDSConnection.new('http://zrzjhb.data.beta.mssds.com/' + @container)
    end
  
    should "respond to get_container" do
      assert_respond_to @connection, :get_container
    end
    
    should "parse containers out of the path" do
      uri = '/infozerk/12'
      assert_equal 'infozerk', @connection.get_container(uri)
    end
    
    should "respond to get_id" do
      assert_respond_to @connection, :get_id
    end
    
    should "parse ids out of the path" do
      uri = "/infozerk/car/1"
      assert_equal '1', @connection.get_id(uri)
    end
    should "parse ids out of the path with .xml extension" do
      uri = "/infozerk/car/1.xml"
      assert_equal '1', @connection.get_id(uri)
    end
    
    should "parse an authority out of the path" do
      uri = "http://infozerktest15.data.beta.mssds.com/infozerk"
      assert_equal 'infozerktest15', @connection.get_authority(uri)
    end
    
    should "parse a URL out of the path" do
      uri = "http://infozerktest15.data.beta.mssds.com/infozerk"
      assert_equal 'data.beta.mssds.com', @connection.get_url(uri)
    end
    
    should "parse a URL out of the path with trailing slash" do
      uri = "http://infozerktest15.data.beta.mssds.com/infozerk/"
      assert_equal 'data.beta.mssds.com', @connection.get_url(uri)
    end
    
  end
end