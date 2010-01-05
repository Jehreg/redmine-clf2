class AddFrenchNameToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :name_fr, :string
  end
  
  def self.down
    remove_column :projects, :name_fr
  end
end
