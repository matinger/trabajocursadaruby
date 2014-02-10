class CreateBookings < ActiveRecord::Migration
  def up
  end

  def down
  end

  def change
      create_table :bookings do |t|
          t.belongs_to :resource
          t.belongs_to :user
          t.string :status
          t.datetime :start
          t.datetime :end_time
          t.timestamps
      end
  end
end
