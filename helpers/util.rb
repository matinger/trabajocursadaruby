module Util

  def bookings_from_resource_with_date(resource_id, start_date, end_date, status)
    status_query = status.nil? ? "" : (" AND status = '"+status+"'")
    Resource.find_by_id(resource_id).bookings.where("start < :end_date AND end_time > :start_date " + status_query, {start_date: start_date, end_date: end_date}).order("start ASC")
  end

  def availability_resource_with_date(resource_id, start_date, end_date, status)
    bookings_from_resource_with_date(resource_id, start_date, end_date, "approved")
  end

  def book_exists?(book_id)
    return Booking.exists?(book_id)
  end

  def resource_exists?(resource_id)
    return Resource.exists?(resource_id)
  end

  def does_resource_approved_book(resource_id, book_id,start_time, end_time)
    bookings = bookings_from_resource_with_date(resource_id, start_time, end_time, "approved")
    return bookings.nil?
  end

  def isAvailable?(datetimeSTART, datetimeEND, bookings_approved)
    space_free_init = datetimeSTART
    space_free_finish = datetimeSTART
    availability_dates = []
    bookings_approved.each do |x|
        if x.start <= space_free_init
            space_free_init = x.end_time
        else 
          space_free_finish = x.start
          availability_dates << {from: space_free_init.strftime('%Y-%m-%dT%H:%M:%SZ'), to: space_free_finish.strftime('%Y-%m-%dT%H:%M:%SZ'), links:[link_resource(params[:number], false)]}
          space_free_init = x.end_time
        end
    end

    if(space_free_init < datetimeEND)
      
      availability_dates << {from: space_free_init.strftime('%Y-%m-%dT%H:%M:%SZ') , to: datetimeEND.strftime('%Y-%m-%dT%H:%M:%SZ') , links:[link_resource(params[:number], false)]}
    end
    availability_dates
  end

end