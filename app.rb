require 'bundler'
require 'sinatra'
require 'sinatra/activerecord'
require_relative 'model/resource'
require_relative 'model/booking'
require_relative 'model/user'
require_relative 'helpers/links.rb'
require_relative 'helpers/util.rb'
require 'json'

include Links
include Util

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
  url = [{rel: :self, uri: url('/resources')}]
  resources = Resource.all.inject([]) {|sum, x| sum << x.resource_json.merge({links: [link_resource(x.id)]})}
  #resources = Resource.all.inject([]) {|sum, x| sum << {name: x.name, description: x.description, links: [link_resource(x.id)]}}
  JSON.pretty_generate({resources: resources, links: url})
end

get '/resources/:name' do
  res = Resource.find_by_id(params[:name])
  JSON.pretty_generate({resource: {name: res.name, description: res.description, links: [{rel: "self", uri: url("/resources/#{res.id}")}, {rel: "bookings", uri: url("/resources/#{res.id}/bookings")} ]}})
end

get '/resources/:number/bookings' do
  return 404 unless resource_exists?(params[:number])
  datetimeconv = params.has_key?("date") ? DateTime.iso8601(params["date"]+'T00:00:00Z') : DateTime.iso8601((Date.today + 1).to_s)
  limit = params.has_key?("limit") ? params["limit"] : "30"
  status = params.has_key?("status") ? params["status"] : "approved"
  status = nil if (status == "all")
  bookings = bookings_from_resource_with_date(params[:number].to_i, datetimeconv, datetimeconv + limit.to_i, params["status"])
  bookingsJSON = bookings.inject([]) {|sum, x| sum << {start: x.start, end: x.end_time, status: x.status, user: User.find_by_id(x.user_id).name, links: links_booking(params[:number], x.id) }}
  status 200
  JSON.pretty_generate({bookings: bookingsJSON, links: [{rel: "self", uri: request.url}]})
end


get '/resources/:number/availability' do
  return 400 unless params.has_key?("date")
  datetimeSTART = DateTime.iso8601(params["date"]+'T00:00:00Z')
  datetimeEND = DateTime.iso8601(params["date"]+'T00:00:00Z') + params["limit"].to_i
  bookings_approved = availability_resource_with_date(params[:number], datetimeSTART, datetimeEND, "approved")
  
  JSON.pretty_generate(isAvailable?(datetimeSTART, datetimeEND, bookings_approved))
end

post '/resources/:number/bookings' do
  return 400 unless params.has_key?('from') and params.has_key?('to')
  datetimeSTART = DateTime.iso8601(params["from"])
  datetimeEND = DateTime.iso8601(params["to"]) 
  user = params.has_key?("user") ? User.find_by_name(params["user"]) : User.find_by_name(ENV['USER_DEFAULT'])
  bookings = bookings_from_resource_with_date(params[:number], datetimeSTART, datetimeEND, "approved")
  if bookings.empty?
    book = Booking.create(start: datetimeSTART, end_time: datetimeEND, resource_id: params[:number], user_id: user.id, status: "pending")
    status 201
    return JSON.pretty_generate({book: {from: book.start.strftime('%Y-%m-%dT%H:%M:%SZ'), to: book.end_time.strftime('%Y-%m-%dT%H:%M:%SZ'), status: book.status,
     links: [uri_booking(params[:number], book.id, "self"), link_book_accept(params[:number], book.id ), link_book_reject(params[:number], book.id ) ]}})
  else
    return 409 
  end
end

get '/resources/:number/bookings/:numberbook' do
  book = Booking.find_by_id(params[:numberbook])
  return JSON.pretty_generate({from: book.start, to: book.end_time, status: book.status,
     links: [uri_booking(params[:number], book.id, "self"), link_resource(params[:number], false), link_book_accept(params[:number], book.id ), link_book_reject(params[:number], book.id ) ]})
end

delete '/resources/:number/bookings/:numberbook' do
  return 404 unless book_exists?(params[:numberbook])
  book = Booking.destroy(params[:numberbook])
  status 200
end

put '/resources/:number/bookings/:numberbook' do
  return 404 unless book_exists?(params[:numberbook])
  book = Booking.find_by_id(params[:numberbook])
  return 409 if does_resource_approved_book(params[:number],params[:numberbook], book.start, book.end_time)
  status 200
  book.status = 'approved'
  book.save
  bookings = bookings_from_resource_with_date(params[:number], book.start, book.end_time, "pending")
  bookings.each do |x|
    x.status = 'canceled'
    x.save
  end 
  JSON.pretty_generate({book: {from: book.start, to: book.end_time, status: book.status,
     links: [uri_booking(params[:number], book.id, "self"),
      link_book_accept(params[:number], book.id ),
      link_book_reject(params[:number], book.id ),
      link_resource(params[:number], false) ]}})
end