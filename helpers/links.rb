module Links
	def link_resource(resource_id, rel=true)
	  {rel: rel ? "self" : "resource", uri: url("/resources/#{resource_id}")}
	end

	def link_accept_booking(uri, value=true)
	  {rel: value ? "accept" : "reject", uri: uri, method: value ? "PUT" : "DELETE"}
	end

	def links_booking(resource_id, booking_id)
		uri_booking = url("/resource/#{resource_id}/bookings/#{booking_id}")
	  [] << {rel: "self", uri: uri_booking} << link_resource(resource_id, false) << link_accept_booking(uri_booking) << link_accept_booking(uri_booking, false)
	end	
end
