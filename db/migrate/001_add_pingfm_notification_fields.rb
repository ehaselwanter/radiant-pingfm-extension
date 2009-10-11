class AddPingfmNotificationFields < ActiveRecord::Migration
  def self.up
    add_column :pages, :notify_pingfm_of_children, :boolean, :default => false
    add_column :pages, :already_notified_pingfm, :boolean, :default => false
  end
  
  def self.down
    remove_column :pages, :notify_pingfm_of_children
    remove_column :pages, :already_notified_pingfm
  end
end