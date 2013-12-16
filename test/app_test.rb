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
  
  def test_createResource
  	Resource.create(name: "Computadora") 
  	assert_equal 1, Resource.all.size
  	user = Resource.first
  	p "USUARIO CON NOMBRE " + user.name
  end
end
