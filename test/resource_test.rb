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
  
  def test_bookings_with_date_1
  	res1 = Resource.create(name: "Computadora", description: "i3") 
    user1 = User.create(name: "admin@admin.com")
    Booking.create(start: DateTime.iso8601('2014-02-01T10:00:00Z'), end_time: DateTime.iso8601('2014-02-01T11:00:00Z'), user_id: user1.id, resource_id: res1.id, status: "approved")
    bookings = res1.bookings_with_date(DateTime.iso8601('2014-02-01T12:00:00Z'), DateTime.iso8601('2014-02-01T13:00:00Z'), nil)
    assert bookings.empty?
  end
  
  def test_bookings_with_date_2
  	res1 = Resource.create(name: "Computadora", description: "i3") 
    user1 = User.create(name: "admin@admin.com")
    Booking.create(start: DateTime.iso8601('2014-02-01T10:00:00Z'), end_time: DateTime.iso8601('2014-02-01T11:00:00Z'), user_id: user1.id, resource_id: res1.id, status: "approved")
    bookings = res1.bookings_with_date(DateTime.iso8601('2014-02-01T09:00:00Z'), DateTime.iso8601('2014-02-01T10:00:00Z'), nil)
    assert bookings.empty?
  end

  def test_bookings_with_date_3
  	res1 = Resource.create(name: "Computadora", description: "i3") 
    user1 = User.create(name: "admin@admin.com")
    Booking.create(start: DateTime.iso8601('2014-02-01T10:00:00Z'), end_time: DateTime.iso8601('2014-02-01T11:00:00Z'), user_id: user1.id, resource_id: res1.id, status: "approved")
    bookings = res1.bookings_with_date(DateTime.iso8601('2014-02-01T09:30:00Z'), DateTime.iso8601('2014-02-01T10:30:00Z'), nil)
    refute bookings.empty?
    assert_equal(bookings.first.start, '2014-02-01T10:00:00Z')
    assert_equal(bookings.first.end_time, '2014-02-01T11:00:00Z')
  end

  def test_bookings_with_date_4
	res1 = Resource.create(name: "Computadora", description: "i3") 
    user1 = User.create(name: "admin@admin.com")
    Booking.create(start: DateTime.iso8601('2014-02-01T10:00:00Z'), end_time: DateTime.iso8601('2014-02-01T11:00:00Z'), user_id: user1.id, resource_id: res1.id, status: "approved")
    bookings = res1.bookings_with_date(DateTime.iso8601('2014-02-01T10:00:00Z'), DateTime.iso8601('2014-02-01T12:00:00Z'), nil)
    refute bookings.empty?
    assert_equal(bookings.first.start, '2014-02-01T10:00:00Z')
    assert_equal(bookings.first.end_time, '2014-02-01T11:00:00Z')
  end

  def test_bookings_with_date_5
	res1 = Resource.create(name: "Computadora", description: "i3") 
    user1 = User.create(name: "admin@admin.com")
    Booking.create(start: DateTime.iso8601('2014-02-01T10:00:00Z'), end_time: DateTime.iso8601('2014-02-01T11:00:00Z'), user_id: user1.id, resource_id: res1.id, status: "approved")
    bookings = res1.bookings_with_date(DateTime.iso8601('2014-02-01T09:30:00Z'), DateTime.iso8601('2014-02-01T11:30:00Z'), nil)
    refute bookings.empty?
    assert_equal(bookings.first.start, '2014-02-01T10:00:00Z')
    assert_equal(bookings.first.end_time, '2014-02-01T11:00:00Z')
  end

  def test_bookings_with_date_6
	res1 = Resource.create(name: "Computadora", description: "i3") 
    user1 = User.create(name: "admin@admin.com")
    Booking.create(start: DateTime.iso8601('2014-02-01T10:00:00Z'), end_time: DateTime.iso8601('2014-02-01T11:00:00Z'), user_id: user1.id, resource_id: res1.id, status: "approved")
    bookings = res1.bookings_with_date(DateTime.iso8601('2014-02-01T09:00:00Z'), DateTime.iso8601('2014-02-01T11:00:00Z'), nil)
    refute bookings.empty?
    assert_equal(bookings.first.start, '2014-02-01T10:00:00Z')
    assert_equal(bookings.first.end_time, '2014-02-01T11:00:00Z')
  end

  def test_bookings_with_date_7
	res1 = Resource.create(name: "Computadora", description: "i3") 
    user1 = User.create(name: "admin@admin.com")
    Booking.create(start: DateTime.iso8601('2014-02-01T10:00:00Z'), end_time: DateTime.iso8601('2014-02-01T11:00:00Z'), user_id: user1.id, resource_id: res1.id, status: "approved")
    bookings = res1.bookings_with_date(DateTime.iso8601('2014-02-01T09:00:00Z'), DateTime.iso8601('2014-02-01T11:00:00Z'), nil)
    refute bookings.empty?
    assert_equal(bookings.first.start, '2014-02-01T10:00:00Z')
    assert_equal(bookings.first.end_time, '2014-02-01T11:00:00Z')
  end

  def test_bookings_with_date_8
	res1 = Resource.create(name: "Computadora", description: "i3") 
    user1 = User.create(name: "admin@admin.com")
    Booking.create(start: DateTime.iso8601('2014-02-01T10:00:00Z'), end_time: DateTime.iso8601('2014-02-01T11:00:00Z'), user_id: user1.id, resource_id: res1.id, status: "approved")
    bookings = res1.bookings_with_date(DateTime.iso8601('2014-02-01T10:30:00Z'), DateTime.iso8601('2014-02-01T11:30:00Z'), nil)
    refute bookings.empty?
    assert_equal(bookings.first.start, '2014-02-01T10:00:00Z')
    assert_equal(bookings.first.end_time, '2014-02-01T11:00:00Z')
  end

  def test_bookings_with_date_09
	res1 = Resource.create(name: "Computadora", description: "i3") 
    user1 = User.create(name: "admin@admin.com")
    Booking.create(start: DateTime.iso8601('2014-02-01T10:00:00Z'), end_time: DateTime.iso8601('2014-02-01T11:00:00Z'), user_id: user1.id, resource_id: res1.id, status: "approved")
    bookings = res1.bookings_with_date(DateTime.iso8601('2014-02-01T09:00:00Z'), DateTime.iso8601('2014-02-01T13:00:00Z'), nil)
    refute bookings.empty?
    assert_equal(bookings.first.start, '2014-02-01T10:00:00Z')
    assert_equal(bookings.first.end_time, '2014-02-01T11:00:00Z')
  end

  def test_bookings_with_date_10
	res1 = Resource.create(name: "Computadora", description: "i3") 
    user1 = User.create(name: "admin@admin.com")
    Booking.create(start: DateTime.iso8601('2014-02-01T10:00:00Z'), end_time: DateTime.iso8601('2014-02-01T11:00:00Z'), user_id: user1.id, resource_id: res1.id, status: "approved")
    bookings = res1.bookings_with_date(DateTime.iso8601('2014-02-01T11:00:00Z'), DateTime.iso8601('2014-02-01T12:00:00Z'), nil)
	assert bookings.empty?
  end

  def test_bookings_with_date_11
	res1 = Resource.create(name: "Computadora", description: "i3") 
    user1 = User.create(name: "admin@admin.com")
    Booking.create(start: DateTime.iso8601('2014-02-01T10:00:00Z'), end_time: DateTime.iso8601('2014-02-01T11:00:00Z'), user_id: user1.id, resource_id: res1.id, status: "approved")
    bookings = res1.bookings_with_date(DateTime.iso8601('2014-02-01T11:30:00Z'), DateTime.iso8601('2014-02-01T12:00:00Z'), nil)
	assert bookings.empty?
  end

  def test_bookings_with_date_status_all
	res1 = Resource.create(name: "Computadora", description: "i3") 
    user1 = User.create(name: "admin@admin.com")
    Booking.create(start: DateTime.iso8601('2014-02-01T10:00:00Z'), end_time: DateTime.iso8601('2014-02-01T11:00:00Z'), user_id: user1.id, resource_id: res1.id, status: "approved")
    Booking.create(start: DateTime.iso8601('2014-02-01T11:00:00Z'), end_time: DateTime.iso8601('2014-02-01T12:00:00Z'), user_id: user1.id, resource_id: res1.id, status: "pending")
    bookings = res1.bookings_with_date(DateTime.iso8601('2014-02-01T10:00:00Z'), DateTime.iso8601('2014-02-01T12:00:00Z'), nil)
    refute bookings.empty?
    book = bookings.shift
    assert_equal(book.start, '2014-02-01T10:00:00Z')
    assert_equal(book.end_time, '2014-02-01T11:00:00Z')
    book = bookings.shift
    assert_equal(book.start, '2014-02-01T11:00:00Z')
    assert_equal(book.end_time, '2014-02-01T12:00:00Z')
  end
  
  def test_bookings_with_date_status_only_one
	res1 = Resource.create(name: "Computadora", description: "i3") 
    user1 = User.create(name: "admin@admin.com")
    Booking.create(start: DateTime.iso8601('2014-02-01T10:00:00Z'), end_time: DateTime.iso8601('2014-02-01T11:00:00Z'), user_id: user1.id, resource_id: res1.id, status: "approved")
    Booking.create(start: DateTime.iso8601('2014-02-01T11:00:00Z'), end_time: DateTime.iso8601('2014-02-01T12:00:00Z'), user_id: user1.id, resource_id: res1.id, status: "pending")
    bookings = res1.bookings_with_date(DateTime.iso8601('2014-02-01T10:00:00Z'), DateTime.iso8601('2014-02-01T12:00:00Z'), "approved")
    refute bookings.empty?
    assert_equal(1, bookings.size)
    book = bookings.shift
    assert_equal(book.start, '2014-02-01T10:00:00Z')
    assert_equal(book.end_time, '2014-02-01T11:00:00Z')
  end

  def test_availabilities_with_date_1
    res1 = Resource.create(name: "Computadora", description: "i3") 
    user1 = User.create(name: "admin@admin.com")
    availabilities = res1.availabilities(DateTime.iso8601('2014-02-01T00:00:00Z'), DateTime.iso8601('2014-02-02T00:00:00Z'))
    assert_equal(1, availabilities.size)
    available = availabilities.shift
    assert_equal(available[:from], '2014-02-01T00:00:00Z')
    assert_equal(available[:to], '2014-02-02T00:00:00Z')

  end

  def test_availabilities_with_date_2
    res1 = Resource.create(name: "Computadora", description: "i3") 
    user1 = User.create(name: "admin@admin.com")
    Booking.create(start: DateTime.iso8601('2014-02-01T10:00:00Z'), end_time: DateTime.iso8601('2014-02-01T11:00:00Z'), user_id: user1.id, resource_id: res1.id, status: "approved")
    availabilities = res1.availabilities(DateTime.iso8601('2014-02-01T00:00:00Z'), DateTime.iso8601('2014-02-02T00:00:00Z'))
    assert_equal(2, availabilities.size)
    available = availabilities.shift
    assert_equal(available[:from], '2014-02-01T00:00:00Z')
    assert_equal(available[:to], '2014-02-01T10:00:00Z')
    available = availabilities.shift
    assert_equal(available[:from], '2014-02-01T11:00:00Z')
    assert_equal(available[:to], '2014-02-02T00:00:00Z')
  end

  def test_availabilities_with_date_3
    res1 = Resource.create(name: "Computadora", description: "i3") 
    user1 = User.create(name: "admin@admin.com")
    Booking.create(start: DateTime.iso8601('2014-01-31T23:00:00Z'), end_time: DateTime.iso8601('2014-02-01T04:00:00Z'), user_id: user1.id, resource_id: res1.id, status: "approved")
    availabilities = res1.availabilities(DateTime.iso8601('2014-02-01T00:00:00Z'), DateTime.iso8601('2014-02-02T00:00:00Z'))
    assert_equal(1, availabilities.size)
    available = availabilities.shift
    assert_equal(available[:from], '2014-02-01T04:00:00Z')
    assert_equal(available[:to], '2014-02-02T00:00:00Z')
  end

  def test_availabilities_with_date_4
    res1 = Resource.create(name: "Computadora", description: "i3") 
    user1 = User.create(name: "admin@admin.com")
    Booking.create(start: DateTime.iso8601('2014-02-01T23:00:00Z'), end_time: DateTime.iso8601('2014-02-02T04:00:00Z'), user_id: user1.id, resource_id: res1.id, status: "approved")
    availabilities = res1.availabilities(DateTime.iso8601('2014-02-01T00:00:00Z'), DateTime.iso8601('2014-02-02T00:00:00Z'))
    assert_equal(1, availabilities.size)
    available = availabilities.shift
    assert_equal(available[:from], '2014-02-01T00:00:00Z')
    assert_equal(available[:to], '2014-02-01T23:00:00Z')
  end

  def test_availabilities_with_date_5
    res1 = Resource.create(name: "Computadora", description: "i3") 
    user1 = User.create(name: "admin@admin.com")
    Booking.create(start: DateTime.iso8601('2014-02-01T00:00:00Z'), end_time: DateTime.iso8601('2014-02-02T04:00:00Z'), user_id: user1.id, resource_id: res1.id, status: "approved")
    availabilities = res1.availabilities(DateTime.iso8601('2014-02-01T00:00:00Z'), DateTime.iso8601('2014-02-02T00:00:00Z'))
    assert_equal(0, availabilities.size)
  end

  def test_availabilities_with_date_6
    res1 = Resource.create(name: "Computadora", description: "i3") 
    user1 = User.create(name: "admin@admin.com")
    Booking.create(start: DateTime.iso8601('2014-01-01T10:00:00Z'), end_time: DateTime.iso8601('2014-01-01T11:00:00Z'), user_id: user1.id, resource_id: res1.id, status: "approved")
    Booking.create(start: DateTime.iso8601('2014-03-01T10:00:00Z'), end_time: DateTime.iso8601('2014-03-01T11:00:00Z'), user_id: user1.id, resource_id: res1.id, status: "approved")
    availabilities = res1.availabilities(DateTime.iso8601('2014-02-01T00:00:00Z'), DateTime.iso8601('2014-02-02T00:00:00Z'))
    assert_equal(1, availabilities.size)
    available = availabilities.shift
    assert_equal(available[:from], '2014-02-01T00:00:00Z')
    assert_equal(available[:to], '2014-02-02T00:00:00Z')
  end
end
