require 'net/http'
require 'date'
require File.dirname(__FILE__) + '/spec_helper'

class SSDSSpec < Test::Unit::TestCase
  context "A service instance" do
    setup do
      @service = SDSRest::Service.new
      @container = random
      @service.create_container @container
    end

    should "respond to :create_entity" do
      assert_respond_to @service, :create_entity
    end

    should "be able to create an entity" do
      results = @service.create_entity @container, 'car', 1, :make => 'BMW', :model => '3-series'
      assert_instance_of Net::HTTPCreated, results
    end

    should "respond to :delete_entity" do
      assert_respond_to @service, :delete_entity
    end

    should "be able to delete an entity" do
      @service.create_entity @container, 'car', 2, :make => 'BMW', :model => '3-series'

      results = @service.delete_entity @container, 2
      assert_instance_of Net::HTTPOK, results
    end

    should "respond to :get_entity" do
      assert_respond_to @service, :get_entity
    end

    should "be able to get an entity" do
      @service.create_entity @container, 'car', 3, :make => 'BMW', :model => '3-series'

      results = @service.get_entity @container, 3
      assert_instance_of Net::HTTPOK, results
    end

    should "respond to :update_entity" do
      assert_respond_to @service, :update_entity
    end

    should "be able to update an entity" do
      @service.create_entity @container, 'car', 4, :make => 'BMW', :model => '3-series'

      results = @service.update_entity @container, 'car', 4, nil, :make => 'Toyota', :mode => '3-series'
      assert_instance_of Net::HTTPOK, results
    end

    should "be able to query" do
      @service.create_entity @container, 'car', 4, :make => 'BMW', :model => '3-series'

      results =  @service.query(@container, 'from c in entities select c')
      assert_instance_of Net::HTTPOK, results

    end

    should "be able to conditionally get" do
      results = @service.create_entity @container, 'car', 4, :make => 'BMW', :model => '3-series'
      version = results['etag']
      results = @service.get_entity @container, 4, version
      assert_instance_of Net::HTTPNotModified, results
    end

    should "be able to conditionally get an updated entity" do
      results = @service.create_entity @container, 'car', 4, :make => 'BMW', :model => '3-series'
      version = results['etag']
      @service.update_entity @container, 'car', 4, nil, :make => 'Toyota', :model => '3-series'
      results = @service.get_entity @container, 4, version
      assert_instance_of Net::HTTPOK, results
    end

    should "be able to conditionally delete correct version" do
      results = @service.create_entity @container, 'car', 4, :make => 'BMW', :model => '3-series'
      version = results['etag']
      results = @service.delete_entity @container, 4, version
      assert_instance_of Net::HTTPOK, results
    end

    should "not be able to conditionally delete wrong version" do
      results = @service.create_entity @container, 'car', 4, :make => 'BMW', :model => '3-series'
      version = results['etag']
      @service.update_entity @container, 'car', 4, nil, :make => 'Toyota', :model => '3-series'
      results = @service.delete_entity @container, 4, version
      assert_instance_of Net::HTTPPreconditionFailed, results
    end

    should "be able to conditionally update correct version" do
      results = @service.create_entity @container, 'car', 4, :make => 'BMW', :model => '3-series'
      version = results['etag']
      results = @service.update_entity @container, 'car', 4, version, :make => 'Toyota', :model => '3-series'
      assert_instance_of Net::HTTPOK, results
    end

    should "not be able to conditionally update wrong version" do
      results = @service.create_entity @container, 'car', 4, :make => 'BMW', :model => '3-series'
      version = results['etag']
      @service.update_entity @container, 'car', 4, nil, :make => 'Toyota', :model => '3-series'
      results = @service.update_entity @container, 'car', 4, version, :make => 'Toyota', :model => '3-series'
      assert_instance_of Net::HTTPPreconditionFailed, results
    end

    should "correctly infer type" do
      assert_equal 'x:string', @service.infer_type('test')
      assert_equal 'x:decimal', @service.infer_type(12)
      assert_equal 'x:decimal', @service.infer_type(12.1)
      assert_equal 'x:boolean', @service.infer_type(true)
      assert_equal 'x:dateTime', @service.infer_type(DateTime.parse('12/12/2006'))

    end

  end
end