require 'facter'
class AddOwnerToHosts < ActiveRecord::Migration
  class User < ActiveRecord::Base; end
  class Host < ActiveRecord::Base; end

  def up
    add_column :hosts, :owner_id,   :integer
    add_column :hosts, :owner_type, :string, :limit => 255

    Host.reset_column_information

    email = SETTINGS[:administrator] || "root@#{Facter.value(:domain)}"
    owner = User.find_by_mail email
    owner ||= User.where(:admin => true).first
    unless owner.nil? or owner.id.nil?
      say "setting default owner for all hosts"
      Host.update_all("owner_id = '#{owner.id}'")
    end
  end

  def down
    remove_column :hosts, :owner_type
    remove_column :hosts, :owner_id
  end
end
