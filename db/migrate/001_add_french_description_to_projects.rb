class AddFrenchDescriptionToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :description_fr, :text
  end
  
  def self.down
    remove_column :projects, :description_fr
  end
end
