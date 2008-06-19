module Mephisto
  module Plugins
    class Feedback
      class Schema < ActiveRecord::Migration
        def self.install
          create_table :feedbacks do |t|
            t.column :site_id, :integer
            t.column :name, :string
            t.column :email, :string
            t.column :body, :text
            t.column :key, :string
            t.column :created_at, :datetime
          end
        end
        
        def self.uninstall
          drop_table :feedbacks
        end
      end
    end
  end
end