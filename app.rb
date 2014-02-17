require 'bundler'
require 'sinatra'
require 'sinatra/activerecord'
require_relative 'model/resource'
require_relative 'model/booking'
require_relative 'model/user'
require_relative 'helpers/generatejson.rb'
require 'json'

ENV['USER_DEFAULT'] ||= 'admin@admin.com'
ENV['RACK_ENV'] ||= 'development'
Bundler.require :default, ENV['RACK_ENV'].to_sym

def load_fixture
  if Resource.all.size < 1
    res1 = Resource.create(name: "Computadora", description: "i3") 
    res2 = Resource.create(name: "Computadora", description: "i5") 
    Resource.create(name: "Computadora", description: "i7") 
    user1 = User.create(name: "admin@admin.com")
    user2= User.create(name: "ezequiel@gmail.com")
    Booking.create(start: DateTime.iso8601('2014-02-01T10:00:00Z'), end_time: DateTime.iso8601('2014-02-01T11:00:00Z'), user_id: user1.id, resource_id: res1.id, status: "approved")
    Booking.create(start: DateTime.iso8601('2014-01-31T10:00:00Z'), end_time: DateTime.iso8601('2014-01-31T11:00:00Z'), user_id: user1.id, resource_id: res1.id, status: "approved")
    Booking.create(start: DateTime.iso8601('2014-01-31T23:00:00Z'), end_time: DateTime.iso8601('2014-02-01T09:00:00Z'), user_id: user1.id, resource_id: res1.id, status: "pending")
    Booking.create(start: DateTime.iso8601('2014-02-01T14:00:00Z'), end_time: DateTime.iso8601('2014-02-01T17:00:00Z'), user_id: user1.id, resource_id: res1.id, status: "approved")
    Booking.create(start: DateTime.iso8601('2014-02-03T14:00:00Z'), end_time: DateTime.iso8601('2014-02-03T17:00:00Z'), user_id: user1.id, resource_id: res1.id, status: "pending")
    Booking.create(start: DateTime.iso8601('2014-02-02T12:00:00Z'), end_time: DateTime.iso8601('2014-02-02T13:00:00Z'), user_id: user2.id, resource_id: res2.id, status: "pending")
    Booking.create(start: DateTime.iso8601('2014-02-02T12:30:00Z'), end_time: DateTime.iso8601('2014-02-02T13:30:00Z'), user_id: user2.id, resource_id: res2.id, status: "pending")
    Booking.create(start: DateTime.iso8601('2014-02-07T12:00:00Z'), end_time: DateTime.iso8601('2014-02-07T13:00:00Z'), user_id: user2.id, resource_id: res2.id, status: "pending")
    Booking.create(start: DateTime.iso8601('2014-02-11T12:00:00Z'), end_time: DateTime.iso8601('2014-02-11T13:00:00Z'), user_id: user2.id, resource_id: res2.id, status: "approved")
    Booking.create(start: DateTime.iso8601('2014-02-11T11:00:00Z'), end_time: DateTime.iso8601('2014-02-11T12:30:00Z'), user_id: user2.id, resource_id: res2.id, status: "pending")
  end
end

load_fixture if ENV['RACK_ENV']=='development'

before do
  content_type :json
end

get '/resources' do
  url = [{rel: "self", uri: url('/resources')}]
  resources = Resource.all.inject([]) {|sum, x| sum << GenerateJson.resource_json(x).merge({links: [GenerateJson.link_resource(x.id, url(""))]})}
  JSON.pretty_generate({resources: resources, links: [GenerateJson.link_self(url("/resources/"))]})
end

get '/resources/:name' do
  return 404 unless Resource.exists?(params[:name].to_i)
  res = Resource.find_by_id(params[:name])
  JSON.pretty_generate({resource: GenerateJson.resource_json(res).merge({links: GenerateJson.link_resource_with_booking(res.id, url("")) }) })
end

get '/resources/:number/bookings' do
  return 404 unless Resource.exists?(params[:number].to_i)
  datetimeconv = params.has_key?("date") ? DateTime.iso8601(params["date"]+'T00:00:00Z') : DateTime.iso8601((Date.today + 1).to_s)
  limit = params.has_key?("limit") ? params["limit"] : "30"
  status = params.has_key?("status") ? params["status"] : "approved"
  status = nil if (status == "all")
  resource = Resource.find_by_id(params[:number].to_i)
  bookings = resource.bookings_with_date(datetimeconv, datetimeconv + limit.to_i, params["status"])
 
  bookingsJSON = bookings.inject([]) {|sum, x| sum << GenerateJson.booking_json(x).merge({ links: GenerateJson.links_booking(params[:number], x.id, url("")) })}
  status 200
  JSON.pretty_generate({bookings: bookingsJSON, links: [GenerateJson.link_self(request.url)]})
end


get '/resources/:number/availability' do
  return 404 unless Resource.exists?(params[:number])
  return 400 unless params.has_key?("date")
  datetimeSTART = DateTime.iso8601(params["date"]+'T00:00:00Z')
  datetimeEND = DateTime.iso8601(params["date"]+'T00:00:00Z') + params["limit"].to_i
  resource = Resource.find_by_id(params[:number].to_i)
  bookings_approved = resource.availabilities(datetimeSTART, datetimeEND).collect {|x| x.merge({links: GenerateJson.links_availability(params[:number], url(""))} )} 
  JSON.pretty_generate({ availability: bookings_approved, links: [{rel: "self", uri: request.url}] })
end

post '/resources/:number/bookings' do
  return 404 unless Resource.exists?(params[:number])
  return 400 unless params.has_key?('from') and params.has_key?('to')
  datetimeSTART = DateTime.iso8601(params["from"])
  datetimeEND = DateTime.iso8601(params["to"]) 
  user = params.has_key?("user") ? User.find_by_name(params["user"]) : User.find_by_name(ENV['USER_DEFAULT'])
  resource = Resource.find_by_id(params[:number].to_i)
  bookings = resource.bookings_with_date(datetimeSTART, datetimeEND, "approved")
  if bookings.empty?
    book = Booking.create(start: datetimeSTART, end_time: datetimeEND, resource_id: params[:number], user_id: user.id, status: "pending")
    status 201
    return JSON.pretty_generate({book: GenerateJson.book_json(book).merge({ links: GenerateJson.links_book(params[:number], book.id, url("")) })})
  else
    return 409 
  end
end

get '/resources/:number/bookings/:numberbook' do
  return 404 unless Resource.exists?(params[:number])
  book = Booking.find_by_id(params[:numberbook])
  return JSON.pretty_generate(GenerateJson.book_json(book).merge({ links: GenerateJson.links_booking(params[:number], book.id, url("")) }) )
end

delete '/resources/:number/bookings/:numberbook' do
  return 404 unless Resource.exists?(params[:number])
  return 404 unless Booking.exists?(params[:numberbook])
  book = Booking.destroy(params[:numberbook])
  status 200
end

put '/resources/:number/bookings/:numberbook' do
  return 404 unless Resource.exists?(params[:number])
  return 404 unless Booking.exists?(params[:numberbook])
  book = Booking.find_by_id(params[:numberbook])
  resource = Resource.find_by_id(params[:number].to_i)
  return 409 if resource.bookings_with_date(book.start, book.end_time, "approved").nil?
  status 200
  book.status = 'approved'
  book.save
  resource = Resource.find_by_id(params[:number].to_i)
  bookings =  resource.bookings_with_date( book.start, book.end_time, "pending")
  bookings.each do |x|
    x.status = 'canceled'
    x.save
  end 
  JSON.pretty_generate({book: GenerateJson.book_json(book).merge({ links: GenerateJson.links_booking_put(params[:number], book.id, url("")) }) })
end