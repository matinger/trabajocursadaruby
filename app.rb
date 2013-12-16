require 'bundler'
require 'sinatra'
require 'sinatra/activerecord'
require_relative 'model/resource'
require_relative 'model/booking'
require_relative 'model/user'
require_relative 'helpers/links.rb'
require 'json'

include Links
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
    Booking.create(start: DateTime.iso8601('2014-02-01T10:00:00+00:00'), end: DateTime.iso8601('2014-02-01T11:00:00+00:00'), user_id: user1.id, resource_id: res1.id, status: "approved")
    Booking.create(start: DateTime.iso8601('2014-01-31T10:00:00+00:00'), end: DateTime.iso8601('2014-01-31T11:00:00+00:00'), user_id: user1.id, resource_id: res1.id, status: "approved")
    Booking.create(start: DateTime.iso8601('2014-01-31T23:00:00+00:00'), end: DateTime.iso8601('2014-02-01T09:00:00+00:00'), user_id: user1.id, resource_id: res1.id, status: "pending")
    Booking.create(start: DateTime.iso8601('2014-02-01T14:00:00+00:00'), end: DateTime.iso8601('2014-02-01T17:00:00+00:00'), user_id: user1.id, resource_id: res1.id, status: "approved")
    Booking.create(start: DateTime.iso8601('2014-02-03T14:00:00+00:00'), end: DateTime.iso8601('2014-02-03T17:00:00+00:00'), user_id: user1.id, resource_id: res1.id, status: "pending")
    Booking.create(start: DateTime.iso8601('2014-02-02T12:00:00+00:00'), end: DateTime.iso8601('2014-02-02T13:00:00+00:00'), user_id: user2.id, resource_id: res2.id, status: "pending")
    res1.bookings.each {|x| p x.start }
  end
end

def bookings_from_resource_with_date(resource_id, start_date, end_date, status)
  status_query = status.nil? ? "" : (" AND status = '"+status+"'")
  Resource.find_by_id(resource_id).bookings.where("start < :end_date AND end > :start_date " + status_query, {start_date: start_date, end_date: end_date}).order("start ASC")
end

def availability_resource_with_date(resource_id, start_date, end_date, status)
  bookings_from_resource_with_date(resource_id, start_date, end_date, "approved")
end

get '/resources' do
	url = [{rel: :self, uri: url('/resources')}]
	resources = Resource.all.inject([]) {|sum, x| sum << {name: x.name, description: x.description, links: [link_resource(x.id)]}}
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
  bookingsJSON = bookings.inject([]) {|sum, x| sum << {start: x.start, end: x.end, status: x.status, user: User.find_by_id(x.user_id).name, links: links_booking(params[:number], x.id) }}
  JSON.pretty_generate({bookings: bookingsJSON, links: [{rel: "self", uri: request.url}]})
end

get '/resources/:number/availability' do
  datetimeSTART = DateTime.iso8601(params["date"]+'T00:00:00')
  datetimeEND = datetimeconv + params["limit"].to_i
  bookings_approved = availability_resource_with_date(params[:number], datetimeconv, datetimeEND, "approved")
  
  availability_dates = []
  space_free_init = datetimeStart
  space_free_finish = datetimeStart
  booking_approved.each do |x|
    if x.start <= space_free_init
        space_free_init = x.end
    else 
      space_free_finish = x.start
      availability_dates << {from: space_free_init, to: space_free_finish, links:[link_resource(params[:number], false)]}
      space_free_init = x.end
    end

end