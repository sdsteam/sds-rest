require 'net/http'

require File.dirname(__FILE__) + '/spec_helper'

class Car < SDSActiveResource::Base
   
  
end

class SDSSpec < Test::Unit::TestCase
  context "An SDSActiveResource class" do
    setup do
      
      @service = SDSRest::Service.new
      @container = random
      @service.create_container @container
      # enter your authority here
      Car.site = 'https://zrzjhb.data.database.windows.net/' + @container + "/"
      Car.user = ENV['username']
      Car.password = ENV['password']
    end
    
    should "be able to save an entity" do
      car = Car.new
      car.make = 'Toyota'
      car.model = '3-series'
      car.Id = "2"
      assert_equal car.save, true
      assert_equal car.Id, car.id
    end
    
    should "be able to destroy an entity" do
      car = get_test_entity
      assert_instance_of Net::HTTPOK, car.destroy
    end
    
    should "be able to update an entity" do
      car = get_test_entity
      car.make = 'BMW'
      car.year = 2007
      assert_equal car.save, true
    end
    
    should "be able to find an entity" do
      car = get_test_entity
      foundcar = Car.find(car.Id)
      assert_not_nil foundcar
      assert_equal foundcar.Id.to_s, car.Id.to_s
      assert_equal 2007, foundcar.year
      assert_equal true, foundcar.for_sale
      assert_equal DateTime.parse("1/1/2007"), foundcar.created
      assert_equal 1.4, foundcar.miles
    end
    
    should "be able to find all entities" do
      get_test_entity
      get_test_entity
      cars = Car.find(:all)
      assert_equal cars.length, 2
      assert_equal cars[0].make, 'toyota'
      assert_equal cars[0].year, 2007
    end
    
    should "be able to query entities" do
      get_test_entity
      car = Car.new()
      car.make = 'ford'
      car.Id = rand(999999)
      car.save
      cars = Car.query('from c in entities where c.Kind == "Car" and c["make"] == "toyota" select c')
      assert_equal 1, cars.length
    end
    
  end
  
  def get_test_entity
    car = Car.new()
    car.make = 'toyota'
    car.Id = rand(999999)
    car.year = 2007
    car.for_sale = true
    car.created = DateTime.parse("1/1/2007")
    car.miles = 1.4
    car.save
    car
  end
  
end