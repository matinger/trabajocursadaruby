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
  
  def test_resources_valid
    res1 = Resource.create(name: "Computadora", description: "i3") 
    get '/resources'
    assert_equal 200, last_response.status
    assert_equal "application/json;charset=utf-8", last_response.content_type
  end

  def test_resource_valid
    res1 = Resource.create(name: "Computadora", description: "i3") 
    get '/resources/1'
    assert_equal 200, last_response.status
    assert_equal "application/json;charset=utf-8", last_response.content_type
  end

  def test_resource_with_invalid_resource
    res1 = Resource.create(name: "Computadora", description: "i3") 
    get '/resources/1000'
    assert_equal 404, last_response.status
    assert_equal "application/json;charset=utf-8", last_response.content_type
  end

  def test_get_bookings_with_date
    res1 = Resource.create(name: "Computadora", description: "i3") 
    user1 = User.create(name: "admin@admin.com")
    Booking.create(start: DateTime.iso8601('2014-02-01T10:00:00Z'), end_time: DateTime.iso8601('2014-02-01T11:00:00Z'), user_id: user1.id, resource_id: res1.id, status: "approved")
    get '/resources/1/bookings', "date" => "2014-02-01"
    assert_equal 200, last_response.status
  end

  def test_get_bookings_with_date_and_limit
    res1 = Resource.create(name: "Computadora", description: "i3") 
    user1 = User.create(name: "admin@admin.com")
    Booking.create(start: DateTime.iso8601('2014-02-01T10:00:00Z'), end_time: DateTime.iso8601('2014-02-01T11:00:00Z'), user_id: user1.id, resource_id: res1.id, status: "approved")
    get '/resources/1/bookings', "date" => "2014-02-01", "limit" => "1"
    assert_equal 200, last_response.status
  end

  def test_get_bookings_with_date_and_limit_and_status
    res1 = Resource.create(name: "Computadora", description: "i3") 
    user1 = User.create(name: "admin@admin.com")
    Booking.create(start: DateTime.iso8601('2014-02-01T10:00:00Z'), end_time: DateTime.iso8601('2014-02-01T11:00:00Z'), user_id: user1.id, resource_id: res1.id, status: "approved")
    get '/resources/1/bookings', "date" => "2014-02-01", "limit" => "1", "status" => "approved"  
    assert_equal 200, last_response.status
  end

  def test_get_bookings_with_invalid_date
    res1 = Resource.create(name: "Computadora", description: "i3") 
    get '/resources/1/bookings', "date" => "37"
    assert_equal 400, last_response.status
  end

  def test_get_bookings_with_invalid_resource
    res1 = Resource.create(name: "Computadora", description: "i3") 
    get '/resources/1000/bookings'
    assert_equal 404, last_response.status
  end

  def test_get_availability_with_date
    res1 = Resource.create(name: "Computadora", description: "i3") 
    user1 = User.create(name: "admin@admin.com")
    Booking.create(start: DateTime.iso8601('2014-02-01T10:00:00Z'), end_time: DateTime.iso8601('2014-02-01T11:00:00Z'), user_id: user1.id, resource_id: res1.id, status: "approved")
    get '/resources/1/availability', "date" => "2014-02-01"
    assert_equal 400, last_response.status
  end
  
  def test_get_availability_with_date_and_limit
    res1 = Resource.create(name: "Computadora", description: "i3") 
    user1 = User.create(name: "admin@admin.com")
    Booking.create(start: DateTime.iso8601('2014-02-01T10:00:00Z'), end_time: DateTime.iso8601('2014-02-01T11:00:00Z'), user_id: user1.id, resource_id: res1.id, status: "approved")
    get '/resources/1/availability', "date" => "2014-02-01", "limit" => "1"
    assert_equal 200, last_response.status
  end

  def test_get_availability_no_parameters
    res1 = Resource.create(name: "Computadora", description: "i3") 
    user1 = User.create(name: "admin@admin.com")
    Booking.create(start: DateTime.iso8601('2014-02-01T10:00:00Z'), end_time: DateTime.iso8601('2014-02-01T11:00:00Z'), user_id: user1.id, resource_id: res1.id, status: "approved")
    get '/resources/1/availability'
    assert_equal 400, last_response.status
  end

  def test_get_availability_with_invalid_date
    res1 = Resource.create(name: "Computadora", description: "i3") 
    user1 = User.create(name: "admin@admin.com")
    Booking.create(start: DateTime.iso8601('2014-02-01T10:00:00Z'), end_time: DateTime.iso8601('2014-02-01T11:00:00Z'), user_id: user1.id, resource_id: res1.id, status: "approved")
    get '/resources/1/availability', "date" => "37", "limit" => "1"
    assert_equal 400, last_response.status
  end

  def test_get_availability_with_invalid_resource
    res1 = Resource.create(name: "Computadora", description: "i3") 
    user1 = User.create(name: "admin@admin.com")
    Booking.create(start: DateTime.iso8601('2014-02-01T10:00:00Z'), end_time: DateTime.iso8601('2014-02-01T11:00:00Z'), user_id: user1.id, resource_id: res1.id, status: "approved")
    get '/resources/1000/availability', "date" => "2014-02-01", "limit" => "1"
    assert_equal 404, last_response.status
  end

  def test_post_with_valid_parameters
    res1 = Resource.create(name: "Computadora", description: "i3")
    user1 = User.create(name: "admin@admin.com") 
    Booking.create(start: DateTime.iso8601('2014-02-01T10:00:00Z'), end_time: DateTime.iso8601('2014-02-01T11:00:00Z'), user_id: user1.id, resource_id: res1.id, status: "approved")
    post '/resources/1/bookings', "from" => "2014-02-20T14:00:00Z", "to" => "2014-02-20T17:00:00Z"
    assert_equal 201, last_response.status
  end

  def test_post_invalid_resource
    res1 = Resource.create(name: "Computadora", description: "i3")
    user1 = User.create(name: "admin@admin.com") 
    Booking.create(start: DateTime.iso8601('2014-02-01T10:00:00Z'), end_time: DateTime.iso8601('2014-02-01T11:00:00Z'), user_id: user1.id, resource_id: res1.id, status: "approved")
    post '/resources/1000/bookings', "from" => "2014-02-19T14:00:00Z", "to" => "2014-02-19T17:00:00Z"
    assert_equal 404, last_response.status
  end

  def test_post_with_book_approved
    res1 = Resource.create(name: "Computadora", description: "i3")
    user1 = User.create(name: "admin@admin.com") 
    Booking.create(start: DateTime.iso8601('2014-02-19T14:00:00Z'), end_time: DateTime.iso8601('2014-02-19T17:00:00Z'), user_id: user1.id, resource_id: res1.id, status: "approved")
    post '/resources/1/bookings', "from" => "2014-02-19T10:00:00Z", "to" => "2014-02-19T19:00:00Z"
    assert_equal 409, last_response.status
  end

  def test_post_with_invalid_dates
    res1 = Resource.create(name: "Computadora", description: "i3")
    user1 = User.create(name: "admin@admin.com") 
    Booking.create(start: DateTime.iso8601('2014-02-19T14:00:00Z'), end_time: DateTime.iso8601('2014-02-19T17:00:00Z'), user_id: user1.id, resource_id: res1.id, status: "approved")
    post '/resources/1/bookings', "from" => "2014", "to" => "201"
    assert_equal 400, last_response.status
  end

  def test_post_no_from
    res1 = Resource.create(name: "Computadora", description: "i3")
    user1 = User.create(name: "admin@admin.com") 
    Booking.create(start: DateTime.iso8601('2014-02-19T14:00:00Z'), end_time: DateTime.iso8601('2014-02-19T17:00:00Z'), user_id: user1.id, resource_id: res1.id, status: "approved")
    post '/resources/1/bookings', "to" => "2014-02-19T17:00:00Z"
    assert_equal 400, last_response.status
  end

  def test_post_no_to
    res1 = Resource.create(name: "Computadora", description: "i3")
    user1 = User.create(name: "admin@admin.com") 
    Booking.create(start: DateTime.iso8601('2014-02-19T14:00:00Z'), end_time: DateTime.iso8601('2014-02-19T17:00:00Z'), user_id: user1.id, resource_id: res1.id, status: "approved")
    post '/resources/1/bookings', "from" => "2014-02-19T14:00:00Z"
    assert_equal 400, last_response.status
  end

  def test_post_without_from_and_to
    res1 = Resource.create(name: "Computadora", description: "i3")
    user1 = User.create(name: "admin@admin.com") 
    Booking.create(start: DateTime.iso8601('2014-02-19T14:00:00Z'), end_time: DateTime.iso8601('2014-02-19T17:00:00Z'), user_id: user1.id, resource_id: res1.id, status: "approved")
    post '/resources/1/bookings'
    assert_equal 400, last_response.status
  end

  def test_get_book
    res1 = Resource.create(name: "Computadora", description: "i3")
    user1 = User.create(name: "admin@admin.com") 
    Booking.create(start: DateTime.iso8601('2014-02-19T14:00:00Z'), end_time: DateTime.iso8601('2014-02-19T17:00:00Z'), user_id: user1.id, resource_id: res1.id, status: "approved")
    get '/resources/1/bookings/1'
    assert_equal 200, last_response.status
  end

  def test_get_book_invalid_resource
    res1 = Resource.create(name: "Computadora", description: "i3")
    user1 = User.create(name: "admin@admin.com") 
    Booking.create(start: DateTime.iso8601('2014-02-19T14:00:00Z'), end_time: DateTime.iso8601('2014-02-19T17:00:00Z'), user_id: user1.id, resource_id: res1.id, status: "approved")
    get '/resources/1000/bookings/1'
    assert_equal 404, last_response.status
  end

  def test_get_book_invalid_book
    res1 = Resource.create(name: "Computadora", description: "i3")
    user1 = User.create(name: "admin@admin.com") 
    Booking.create(start: DateTime.iso8601('2014-02-19T14:00:00Z'), end_time: DateTime.iso8601('2014-02-19T17:00:00Z'), user_id: user1.id, resource_id: res1.id, status: "approved")
    get '/resources/1/bookings/1000'
    assert_equal 404, last_response.status
  end

  def test_delete
    res1 = Resource.create(name: "Computadora", description: "i3")
    user1 = User.create(name: "admin@admin.com") 
    Booking.create(start: DateTime.iso8601('2014-02-19T14:00:00Z'), end_time: DateTime.iso8601('2014-02-19T17:00:00Z'), user_id: user1.id, resource_id: res1.id, status: "approved")
    delete '/resources/1/bookings/1'
    assert_equal 200, last_response.status
  end

  def test_delete_invalid_resource
    res1 = Resource.create(name: "Computadora", description: "i3")
    user1 = User.create(name: "admin@admin.com") 
    Booking.create(start: DateTime.iso8601('2014-02-19T14:00:00Z'), end_time: DateTime.iso8601('2014-02-19T17:00:00Z'), user_id: user1.id, resource_id: res1.id, status: "approved")
    delete '/resources/1000/bookings/1'
    assert_equal 404, last_response.status
  end

  def test_delete_invalid_book
    res1 = Resource.create(name: "Computadora", description: "i3")
    user1 = User.create(name: "admin@admin.com") 
    Booking.create(start: DateTime.iso8601('2014-02-19T14:00:00Z'), end_time: DateTime.iso8601('2014-02-19T17:00:00Z'), user_id: user1.id, resource_id: res1.id, status: "approved")
    delete '/resources/1/bookings/1000'
    assert_equal 404, last_response.status
  end

  def test_put_with_approved
    res1 = Resource.create(name: "Computadora", description: "i3")
    user1 = User.create(name: "admin@admin.com") 
    book1 = Booking.create(start: DateTime.iso8601('2014-02-19T15:00:00Z'), end_time: DateTime.iso8601('2014-02-19T16:00:00Z'), user_id: user1.id, resource_id: res1.id, status: "approved")
    book2 = Booking.create(start: DateTime.iso8601('2014-02-19T14:00:00Z'), end_time: DateTime.iso8601('2014-02-19T17:00:00Z'), user_id: user1.id, resource_id: res1.id, status: "pending")
    put '/resources/1/bookings/' + book2.id.to_s
    assert_equal 409, last_response.status
  end

  def test_put
    res1 = Resource.create(name: "Computadora", description: "i3")
    user1 = User.create(name: "admin@admin.com") 
    book1 = Booking.create(start: DateTime.iso8601('2014-02-19T15:00:00Z'), end_time: DateTime.iso8601('2014-02-19T16:00:00Z'), user_id: user1.id, resource_id: res1.id, status: "pending")
    put '/resources/1/bookings/' + book1.id.to_s
    assert_equal 200, last_response.status
  end

  def test_put_with_invalid_resource
    res1 = Resource.create(name: "Computadora", description: "i3")
    user1 = User.create(name: "admin@admin.com") 
    Booking.create(start: DateTime.iso8601('2014-02-19T14:00:00Z'), end_time: DateTime.iso8601('2014-02-19T17:00:00Z'), user_id: user1.id, resource_id: res1.id, status: "approved")
    Booking.create(start: DateTime.iso8601('2014-02-19T14:00:00Z'), end_time: DateTime.iso8601('2014-02-19T17:00:00Z'), user_id: user1.id, resource_id: res1.id, status: "pending")
    put '/resources/1000/bookings/1'
    assert_equal 404, last_response.status
  end

  def test_put_with_invalid_book
    res1 = Resource.create(name: "Computadora", description: "i3")
    user1 = User.create(name: "admin@admin.com") 
    Booking.create(start: DateTime.iso8601('2014-02-19T14:00:00Z'), end_time: DateTime.iso8601('2014-02-19T17:00:00Z'), user_id: user1.id, resource_id: res1.id, status: "approved")
    Booking.create(start: DateTime.iso8601('2014-02-19T14:00:00Z'), end_time: DateTime.iso8601('2014-02-19T17:00:00Z'), user_id: user1.id, resource_id: res1.id, status: "pending")
    put '/resources/1/bookings/1000'
    assert_equal 404, last_response.status
  end
end
