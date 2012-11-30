class CreateVisit < ActiveRecord::Migration
  def up
	  create_table :visits do |t|
		  t.integer :url_id
		  t.string :country
	  end
	  add_index :visits, :country
	  add_index :visits, :url_id
  end

  def down
	  drop_table :visits
  end
end
