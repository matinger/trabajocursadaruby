require 'bundler'
require 'sinatra'
require 'sinatra/activerecord'
require_relative 'model/resource'
require_relative 'model/booking'
require_relative 'model/user'
require 'json'

ENV['RACK_ENV'] ||= 'development'
Bundler.require :default, ENV['RACK_ENV'].to_sym

get '/' do
  'Hello World'
end

before do
  content_type :json
  if Resource.all.size < 1
    p "EJECUTANDO CREACIONES"
  	res1 = Resource.create(name: "Computadora", description: "i3") 
  	res2 = Resource.create(name: "Computadora", description: "i5") 
  	Resource.create(name: "Computadora", description: "i7") 
    user1 = User.create(name: "Matias@gmail.com")
    user2= User.create(name: "Ezequiel@gmail.com")
    Booking.create(start: DateTime.iso8601('2014-02-01T10:00:00+00:00'), end: DateTime.iso8601('2014-02-01T11:00:00+00:00'), user_id: user1.id, resource_id: res1.id, status: "pending")
    Booking.create(start: DateTime.iso8601('2014-02-01T14:00:00+00:00'), end: DateTime.iso8601('2014-02-01T17:00:00+00:00'), user_id: user1.id, resource_id: res1.id, status: "pending")
    Booking.create(start: DateTime.iso8601('2014-02-03T14:00:00+00:00'), end: DateTime.iso8601('2014-02-03T17:00:00+00:00'), user_id: user1.id, resource_id: res1.id, status: "pending")
    Booking.create(start: DateTime.iso8601('2014-02-02T12:00:00+00:00'), end: DateTime.iso8601('2014-02-02T13:00:00+00:00'), user_id: user2.id, resource_id: res2.id, status: "pending")

  end
end

def bookings_from_resource_with_date(resource_id, start_date, end_date, status)
  bookings = Booking.where("resource_id = :resource_id  AND status = :status AND start BETWEEN :start_date AND :end_date", 
                          {resource_id: resource_id, start_date: start_date, end_date: end_date, status: status})
end

get '/resources' do
	
	url = [{rel: :self, uri: url('/resources')}]
	resources = Resource.all.inject([]) {|sum, x| sum << {name: x.name, description: x.description, links: [rel: "self", uri: url("/resource/#{x.id}")]}}
	#Resource.all.each { | x | resources << {name: x.name, description: x.description, links: [rel: "self", uri: url("/resource/#{x.id}")]} }

	JSON.pretty_generate({resources: resources, links: url})
end

get '/resources/:name' do
  res = Resource.find_by_id(params[:name])
  JSON.pretty_generate({resource: {name: res.name, description: res.description, links: [{rel: "self", uri: url("/resources/#{res.id}")}, {rel: "bookings", uri: url("/bookings/#{res.id}")} ]}})
end

get '/resources/:number/bookings' do
  
  datetimeconv = DateTime.iso8601(params["date"]+'T00:00:00')
  bookings = bookings_from_resource_with_date(params[:number], datetimeconv, datetimeconv + params["limit"].to_i, params["status"])

  bookingsJSON = bookings.inject([]) {|sum, x| sum << {start: x.start, end: x.end, status: x.status, user: User.find_by_id(x.user_id).name }}
  JSON.pretty_generate({bookings: bookingsJSON})

end