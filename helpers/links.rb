module Links
  def link_resource(resource_id, rel=true)
    {rel: rel ? "self" : "resource", uri: url("/resources/#{resource_id}")}
  end

  def link_accept_booking(uri, value=true)
    {rel: value ? "accept" : "reject", uri: uri, method: value ? "PUT" : "DELETE"}
  end

  def get_uri_booking(resource_id, booking_id)
    url("/resource/#{resource_id}/bookings/#{booking_id}")
  end

  def uri_booking(resource_id, booking_id, rel)
    {rel: rel, uri: get_uri_booking(resource_id, booking_id)}    
  end

  def links_booking(resource_id, booking_id)
    [] << uri_booking(resource_id, booking_id, 'self') << link_resource(resource_id, false) << link_accept_booking(get_uri_booking(resource_id, booking_id)) << link_accept_booking(get_uri_booking(resource_id, booking_id), false)
  end 

  def link_book_accept(resource_id, booking_id )
    uri_booking(resource_id, booking_id, "accept").merge({method: "PUT"})
  end
  
  def link_book_reject(resource_id, booking_id )
    uri_booking(resource_id, booking_id, "reject").merge({method: "DELETE"})
  end
end
