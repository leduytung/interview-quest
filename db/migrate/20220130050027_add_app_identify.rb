class AddAppIdentify < ActiveRecord::Migration[5.2]
  # Only for Postgres
  # def up
  #   execute <<-SQL
  #     CREATE TYPE branches AS ENUM ('jbird', 'bridj');
  #   SQL
  #   add_column :zones, :app_identify, :branches
  #   add_column :bookings, :app_identify, :branches
  #   add_column :travelers, :app_identify, :branches
  #   add_index :zones, :app_identify
  # end

  # def down
  #   remove_column :zones, :app_identify
  #   remove_column :bookings, :app_identify
  #   remove_column :travelers, :app_identify
  #   execute <<-SQL
  #     DROP TYPE app_identify;
  #   SQL
  # end

  def up
    add_column :zones, :app_identify, :integer
    add_column :bookings, :app_identify, :integer
    add_column :travelers, :app_identify, :integer
    add_index :zones, :app_identify
    add_index :bookings, :app_identify
    add_index :travelers, :app_identify
  end

  def down
    remove_column :zones, :app_identify
    remove_column :bookings, :app_identify
    remove_column :travelers, :app_identify
  end
end
