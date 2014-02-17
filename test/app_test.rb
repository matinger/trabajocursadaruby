require 'test_helper'
require_relative '../model/resource.rb'

class AppTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end
  
  def setup
    DatabaseCleaner.start
  end
  
  def teardown
    DatabaseCleaner.clean
  end
  
  def test_resources_correct
    res1 = Resource.create(name: "Computadora", description: "i3") 
    get '/resources'
    assert_equal 200, last_response.status
    assert_equal "application/json;charset=utf-8", last_response.content_type
  end

  def test_resource_correct
    res1 = Resource.create(name: "Computadora", description: "i3") 
    get '/resources/1'
    assert_equal 200, last_response.status
    assert_equal "application/json;charset=utf-8", last_response.content_type
  end

  def test_resource_bad_number_resource
    res1 = Resource.create(name: "Computadora", description: "i3") 
    get '/resources/1000'
    assert_equal 404, last_response.status
    assert_equal "application/json;charset=utf-8", last_response.content_type
  end

  def test_availavility_post_201
    post '/resources/1/bookings', "from" => "2014-02-01T00:00:00Z", "limit" => "1"
    assert_equal 201, last_response.status
  end

  def test_availavility_post_409
    post '/resources/1/bookings', "from" => "2014-02-01T14:00:00Z", "to" => "2014-02-01T17:00:00Z"
    assert_equal 409, last_response.status
  end

  def test_get_bookings
    get '/resources/1/bookings'
    assert_equal 200, last_response.status
  end

  def test_post_without_from
    post '/resources/1/bookings', "to" => Date.today + 10
    assert_equal 400, last_response.status
  end

  def test_delete
    delete '/resources/1/bookings/4'
    assert_equal 200, last_response.status
  end

  def test_put
    put '/resources/2/bookings/7'
    assert_equal 200, last_response.status
  end

end
