class GenerateJson

  def self.resource_json(resource)
    {name: resource.name, description: resource.description}
  end

  def self.link_resource(resource_id, url, rel=true)
    {rel: rel ? "self" : "resource", uri: url+"resources/#{resource_id}"}
  end

  def self.link_self(url)
    {rel: "self", uri: url}
  end

  def self.link_resource_with_booking(resource_id, url)
    [] << self.link_resource(resource_id, url) << {rel: "bookings", uri: url+"resources/#{resource_id}/bookings"}
  end

  def self.links_availability(resource_id, url)
    []  << {rel: "book", uri: url+ "resources/#{resource_id}/bookings", method: "POST"} << self.link_resource(resource_id, url, false)
  end

  def self.booking_json(booking)
    {start: booking.start, end: booking.end_time, status: booking.status, user: User.find_by_id(booking.user_id).name}
  end

  def self.book_json(book)
    {from: book.start, to: book.end_time, status: book.status}
  end

  def self.link_accept_reject_booking(uri, value=true)
    {rel: value ? "accept" : "reject", uri: uri, method: value ? "PUT" : "DELETE"}
  end

  def self.get_uri_booking(resource_id, booking_id, url)
    url + "resources/#{resource_id}/bookings/#{booking_id}"
  end

  def self.uri_booking(resource_id, booking_id, rel , url)
    {rel: rel, uri: get_uri_booking(resource_id, booking_id, url)}    
  end

  def self.links_booking(resource_id, booking_id, url)
    [] << uri_booking(resource_id, booking_id, 'self', url) << self.link_resource(resource_id, url, false) << self.link_accept_reject_booking(get_uri_booking(resource_id, booking_id, url)) << self.link_accept_reject_booking(get_uri_booking(resource_id, booking_id, url), false)
  end 

  def self.links_booking_put(resource_id, booking_id, url)
    [] << uri_booking(resource_id, booking_id, 'self', url) << self.link_accept_reject_booking(get_uri_booking(resource_id, booking_id, url)) << self.link_accept_reject_booking(get_uri_booking(resource_id, booking_id, url), false) << self.link_resource(resource_id, url, false)
  end 

  def self.links_book(resource_id, booking_id, url)
    [] << uri_booking(resource_id, booking_id, 'self', url) << self.link_accept_reject_booking(get_uri_booking(resource_id, booking_id, url)) << self.link_accept_reject_booking(get_uri_booking(resource_id, booking_id, url), false)
  end 

end