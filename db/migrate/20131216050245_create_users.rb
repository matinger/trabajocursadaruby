class CreateUsers < ActiveRecord::Migration
  def up
  end

  def down
  end

    def change
      create_table :users do |t|
          t.string :name
          t.timestamps
      end
  end
end
