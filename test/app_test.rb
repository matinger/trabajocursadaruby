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

  def test_get_root
    get '/'
    assert_equal 200, last_response.status
    assert_equal 'Hello World', last_response.body
  end
  
  def test_availavility_post_201
    post '/resources/1/bookings', "from" => "2014-02-01T00:00:00Z", "to" => "2014-02-01T10:00:00Z"
    assert_equal 201, last_response.status
  end

  def test_availavility_post_409
    post '/resources/1/bookings', "from" => "2014-02-01T14:00:00Z", "to" => "2014-02-01T17:00:00Z"
    assert_equal 409, last_response.status
  end

end
