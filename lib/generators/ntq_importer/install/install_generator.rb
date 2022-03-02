require 'rails/generators'
require 'rails/generators/migration'

module NtqImporter
  module Generators
    class InstallGenerator < ::Rails::Generators::Base

      class_option :db_type, type: :string, default: 'mysql'

      include Rails::Generators::Migration
      source_root File.expand_path('../templates', __FILE__)
      desc "Add the migrations for NtqImporter"

      def self.next_migration_number(path)
        next_migration_number = current_migration_number(path) + 1
        ActiveRecord::Migration.next_migration_number(next_migration_number)
      end

      def copy_templates      
        @db_type = options['db_type']
        if @db_type == "mysql"
          # Migrations
          migration_template "migrations/create_ntq_imports.rb", "db/migrate/create_ntq_imports.rb"
          migration_template "migrations/create_ntq_import_sheets.rb", "db/migrate/create_ntq_import_sheets.rb"
          migration_template "migrations/create_ntq_import_headers.rb", "db/migrate/create_ntq_import_headers.rb"
          migration_template "migrations/create_ntq_import_data.rb", "db/migrate/create_ntq_import_data.rb"
          migration_template "migrations/create_ntq_import_logs.rb", "db/migrate/create_ntq_import_logs.rb"
        elsif @db_type == "mongodb"
        end
      end
      
    end
  end
end