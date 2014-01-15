class AddCustomContactFields < ActiveRecord::Migration
  def up
    add_column :contacts, :xmpp, :string
    add_column :contacts, :twitter, :string
  end

  def down
    remove_column :contacts, :xmpp
    remove_column :contacts, :twitter
  end
end
