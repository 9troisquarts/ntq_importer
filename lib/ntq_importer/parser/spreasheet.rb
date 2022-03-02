module NtqImporter
  module Parser

    class Spreadsheet

      def initialize(file)
        @file = file
        @file_path = ActiveStorage::Blob.service.send(:path_for, file.key)
      end

      def get_data
        wb = nil
        case @file&.blob&.content_type
        when 'application/vnd.ms-excel.sheet.macroenabled.12',
              'application/vnd.ms-excel.sheet.macroEnabled.12',
              'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
          wb = Roo::Excelx.new(@file_path, file_warning: :ignore)
        when 'application/vnd.ms-excel'
          wb = Roo::Excel.new(@file_path, file_warning: :ignore)
        end
        wb_sheets = []
        wb.each_with_pagename do |name, sheet|
          lines = []
          sheet.each do |line|
            lines.push(line)
          end
          wb_sheets.push({
            :name => name,
            :lines => lines
          })
        end
        return {
          :lines => nil,
          :sheets => wb_sheets
        }
      end
    end

  end
end