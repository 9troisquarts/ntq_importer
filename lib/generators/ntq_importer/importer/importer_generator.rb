require 'rails/generators'

module NtqImporter
  module Generators
    class ImporterGenerator < ::Rails::Generators::Base

      class_option :name, type: :string

      source_root File.expand_path('../templates', __FILE__)
      desc "Create a new importer"

      def create_imorter_file
        @name = options['name']
        if @name
          copy_file "application_importer_template.rb", "app/lib/ntq_importers/application_importer.rb"
          template "importer_template.erb", "app/lib/ntq_importers/#{@name}_importer.rb"
        else
          p "Usage: rails g ntq_importer:importer --name your_importer_name"
        end
      end
      
    end
  end
end