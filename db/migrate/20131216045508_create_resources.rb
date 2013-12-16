class CreateResources < ActiveRecord::Migration
  def up
  end

  def down
  end

  def change
      create_table :resources do |t|
          t.string :name
          t.text :description
          t.timestamps
      end
  end
end
