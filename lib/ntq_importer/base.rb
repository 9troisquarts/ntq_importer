require_relative "parser/base" 

module NtqImporter

  class Base

    LOG_TYPE_ERROR = "error".freeze
    LOG_TYPE_WARNING = "warning".freeze
    LOG_TYPE_INFO = "info".freeze

    VALID_LOG_TYPES = [
      LOG_TYPE_ERROR,
      LOG_TYPE_WARNING,
      LOG_TYPE_INFO
    ]

    STATUS_TYPE_INITIALIZED = "initialized".freeze
    STATUS_TYPE_PARSING = "parsing".freeze
    STATUS_TYPE_PARSED = "parsed".freeze
    STATUS_TYPE_PARSED_WITH_ERRORS = "parsed_with_errors".freeze
    STATUS_TYPE_ANALYZING = "analyzing".freeze
    STATUS_TYPE_ANALYZED = "analyzed".freeze
    STATUS_TYPE_ANALYZED_WITH_ERRORS = "analyzed_with_errors".freeze
    STATUS_TYPE_IMPORTING = "importing".freeze
    STATUS_TYPE_IMPORTED = "imported".freeze
    STATUS_TYPE_IMPORTED_WITH_ERRORS = "imported_with_errors".freeze

    VALID_STATUS_TYPES = [
      STATUS_TYPE_INITIALIZED,
      STATUS_TYPE_PARSING,
      STATUS_TYPE_PARSED,
      STATUS_TYPE_PARSED_WITH_ERRORS,
      STATUS_TYPE_ANALYZING,
      STATUS_TYPE_ANALYZED,
      STATUS_TYPE_ANALYZED_WITH_ERRORS,
      STATUS_TYPE_IMPORTING,
      STATUS_TYPE_IMPORTED,
      STATUS_TYPE_IMPORTED_WITH_ERRORS
    ].freeze

    HEADER_DATA_DIRECTION_BOTTOM = "bottom"
    HEADER_DATA_DIRECTION_UP = "up"
    HEADER_DATA_DIRECTION_LEFT = "left"
    HEADER_DATA_DIRECTION_RIGHT = "right"

    HEADER_DATA_TYPE_ANY = "any"
    HEADER_DATA_TYPE_NUMERIC = "numeric"

    attr_accessor :status, :file, :parsed_data, :analyzed_data, :logs, :headers_schema

    def initialize(file)
      @file = file
      @parsed_data = nil
      @analyzed_data = nil
      @status = STATUS_TYPE_INITIALIZED
      @logs = []
      @headers_schema = []
    end

    def parse
      begin
        @status = STATUS_TYPE_PARSING
        @parsed_data = parser.get_data
        @status = STATUS_TYPE_PARSED
      rescue => e
        log = create_log(e, LOG_TYPE_ERROR)
        @logs.push(log) if log
        @status = STATUS_TYPE_PARSED_WITH_ERRORS
      end
    end

    def analyze(continue_on_errors = true)
      begin
        @status = STATUS_TYPE_ANALYZING

        # Headers checking
        headers = []
        @headers_schema.each do |header_schema|
          found_headers = find_headers(header_schema, @parsed_data)
          if found_headers.length == 0
            if header_schema[:required]
              log = create_log("missing_required_header", LOG_TYPE_ERROR, header_schema[:name], true) 
            else
              log = create_log("missing_required_header", LOG_TYPE_WARNING, header_schema[:name], true) 
            end
            @logs.push(log) if log
          else
            headers = headers + found_headers
          end
        end

        # Headers data filling
        filled_headers = fill_headers_data(headers, @parsed_data)
        
        # Empty data checking
        filled_headers_have_data = filled_headers.detect{|fh| fh[:data].length > 0}

        # Errors data checking
        filled_headers_have_data_errors = filled_headers.detect{|fh| fh[:data].detect{|fhd| fhd[:logs].detect{|fhdl| fhdl[:type] == LOG_TYPE_ERROR } } }

        if !filled_headers_have_data || filled_headers_have_data_errors
          @status = STATUS_TYPE_ANALYZED_WITH_ERRORS
        else
          @status = STATUS_TYPE_ANALYZED
        end

        @analyzed_data = {
          logs: @logs,
          headers: filled_headers,
        }
        return @analyzed_data
      rescue
        log = create_log(e, LOG_TYPE_ERROR, nil, true)
        @logs.push(log) if log
        @status = STATUS_TYPE_ANALYZED_WITH_ERRORS
      end
    end

    def import
    end

    private

    def parser
      @parser ||= NtqImporter::Parser::Base.new(@file).parser
    end

    def create_log(message, type = LOG_TYPE_INFO, data = nil, i18n = false)
      return nil if !VALID_LOG_TYPES.detect{|log_type| log_type == type}
      log = {
        type: type,
        message: message.to_s,
        data: data
      }
      return log
    end

    def find_headers(header_schema, parsed_data)
      found_headers = []  
      if header_schema[:sheet_name]
        if header_schema[:sheet_name].is_a? Regexp
          sheet_match = parsed_data[:sheets].detect{|s| s[:name].match(header_schema[:sheet_name]) }
          sheet = sheet_match[0] if sheet_match
        else
          sheet = parsed_data[:sheets].detect{|s| s[:name] == header_schema[:sheet_name] }
        end
        return [] if !sheet
        lines = sheet[:lines]
      else
        lines = parsed_data[:lines] 
      end
      lines.each_with_index do |line, line_index|
        if header_schema[:line_index]
          next unless line_index == header_schema[:line_index]
        end
        line.each_with_index do |column, column_index|
          if header_schema[:column_index]
            next unless column_index == header_schema[:column_index]
          end
          if header_schema[:name].is_a? Regexp
            header_match = header_schema[:name].match(column)
          else
            header_found = header_schema[:name] == column
          end
          if header_match || header_found
            header = {}
            header[:name] = column
            header[:sheet_name] = sheet[:name] if sheet
            header[:line_index] = line_index
            header[:column_index] = column_index
            found_header = {
              schema: header_schema,
              header: header,
              data: []
            }
            found_headers.push(found_header)
          end
        end
      end
      return found_headers
    end

    def fill_headers_data(headers, parsed_data)
      headers.each_with_index do |header, header_index|

        if parsed_data[:sheets]
          sheet = parsed_data[:sheets].detect{|s| s[:name] == header[:header][:sheet_name]}
          lines = sheet[:lines]
        else
          lines = parsed_data[:lines]
        end

        if sheet
          other_headers_for_these_lines = headers.filter{|h| (h[:header][:name] != header[:header][:name] && h[:header][:sheet_name] == header[:header][:sheet_name])}
        else
          other_headers_for_these_lines = headers.filter{|h| h[:header][:name] != header[:header][:name]}
        end

        case header[:schema][:data_direction]
        when HEADER_DATA_DIRECTION_BOTTOM
          data_start_line_index = header[:header][:line_index] + 1
          next if data_start_line_index >= lines.count
          data_end_line_index = lines.count - 1
          next if data_end_line_index <= 0
          data_column_index = header[:header][:column_index]
          current_line_index = data_start_line_index
          while current_line_index <= data_end_line_index
            found_header_at_position = headers.detect{|h| h[:header][:line_index] == current_line_index && h[:header][:column_index] == data_column_index}            
            break if found_header_at_position
            data_content = lines[current_line_index][data_column_index]
            logs = check_data_content_requirements(data_content, header[:schema])
            headers[header_index][:data].push({
              logs: logs,
              content: data_content,
              line_index: current_line_index,
              column_index: data_column_index
            })
            current_line_index += 1
          end
        end
      end  
      return headers
    end

    def check_data_content_requirements(data_content, header_schema)
      logs = []
      if (header_schema[:data_required] && (!data_content || data_content == ""))
        log = create_log("missing_required_data", LOG_TYPE_ERROR, nil, true)
        logs.push(log)
      end
      if (header_schema[:data_required] && header_schema[:data_type] == HEADER_DATA_TYPE_NUMERIC)
        if !is_number?(data_content)
          log = create_log("wrong_data_type", LOG_TYPE_ERROR, nil, true)
          logs.push(log)
        end
      end
      return logs
    end

    def is_number? data
      true if Float(data) rescue false
    end

  end

end