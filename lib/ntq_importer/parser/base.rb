require_relative "spreasheet" 

module NtqImporter
  module Parser

    class Base

      VALID_CONTENT_TYPES = %w[
        text/csv
        text/plain
        application/vnd.ms-excel
        application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
        application/vnd.ms-excel.sheet.macroenabled.12
        application/vnd.ms-excel.sheet.macroEnabled.12
      ].freeze

      attr_accessor :errors

      def initialize(file = nil)
        @file = file
      end

      def parser
        if !@file
          raise "parser_missing_file"
          return nil
        end
        case @file&.blob&.content_type
        when 'application/vnd.ms-excel',
             'application/vnd.ms-excel.sheet.macroEnabled.12',
             'application/vnd.ms-excel.sheet.macroenabled.12',
             'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
          return NtqImporter::Parser::Spreadsheet.new(@file)
        else
          raise "parser_unsupported_file"
          return nil
        end
      end

    end

  end
end