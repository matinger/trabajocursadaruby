class Resource < ActiveRecord::Base
  has_many :bookings
  validates :name, presence: true
  
  def bookings_with_date(start_date, end_date, status)
    status_query = status.nil? ? "" : (" AND status = '"+status+"'")
    bookings.where("start < :end_date AND end_time > :start_date " + status_query, {start_date: start_date, end_date: end_date}).order("start ASC")
  end

  def availabilities(date_time_start, date_time_end)
  	bookings_approved = bookings_with_date(date_time_start, date_time_end, "approved")
  	space_free_init = date_time_start
    space_free_finish = date_time_start
    availability_dates = []
    bookings_approved.each do |x|
        if x.start <= space_free_init
            space_free_init = x.end_time
        else 
          space_free_finish = x.start
          availability_dates << {from: space_free_init.strftime('%Y-%m-%dT%H:%M:%SZ'), to: space_free_finish.strftime('%Y-%m-%dT%H:%M:%SZ')}
          space_free_init = x.end_time
        end
    end
    if(space_free_init < date_time_end)
      availability_dates << {from: space_free_init.strftime('%Y-%m-%dT%H:%M:%SZ') , to: date_time_end.strftime('%Y-%m-%dT%H:%M:%SZ') }
    end
    availability_dates
  end

end