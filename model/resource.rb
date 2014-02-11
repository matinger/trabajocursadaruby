class Resource < ActiveRecord::Base
  has_many :bookings
  validates :name, presence: true

  def resource_json
  	{name: name, description: description}
  end

end