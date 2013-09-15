require 'delegate'
require 'http/header'

module HTTP
  class Response
    include HTTP::Header

    STATUS_CODES = {
      100 => 'Continue',
      101 => 'Switching Protocols',
      102 => 'Processing',
      200 => 'OK',
      201 => 'Created',
      202 => 'Accepted',
      203 => 'Non-Authoritative Information',
      204 => 'No Content',
      205 => 'Reset Content',
      206 => 'Partial Content',
      207 => 'Multi-Status',
      226 => 'IM Used',
      300 => 'Multiple Choices',
      301 => 'Moved Permanently',
      302 => 'Found',
      303 => 'See Other',
      304 => 'Not Modified',
      305 => 'Use Proxy',
      306 => 'Reserved',
      307 => 'Temporary Redirect',
      400 => 'Bad Request',
      401 => 'Unauthorized',
      402 => 'Payment Required',
      403 => 'Forbidden',
      404 => 'Not Found',
      405 => 'Method Not Allowed',
      406 => 'Not Acceptable',
      407 => 'Proxy Authentication Required',
      408 => 'Request Timeout',
      409 => 'Conflict',
      410 => 'Gone',
      411 => 'Length Required',
      412 => 'Precondition Failed',
      413 => 'Request Entity Too Large',
      414 => 'Request-URI Too Long',
      415 => 'Unsupported Media Type',
      416 => 'Requested Range Not Satisfiable',
      417 => 'Expectation Failed',
      418 => "I'm a Teapot",
      422 => 'Unprocessable Entity',
      423 => 'Locked',
      424 => 'Failed Dependency',
      426 => 'Upgrade Required',
      500 => 'Internal Server Error',
      501 => 'Not Implemented',
      502 => 'Bad Gateway',
      503 => 'Service Unavailable',
      504 => 'Gateway Timeout',
      505 => 'HTTP Version Not Supported',
      506 => 'Variant Also Negotiates',
      507 => 'Insufficient Storage',
      510 => 'Not Extended'
    }
    STATUS_CODES.freeze

    SYMBOL_TO_STATUS_CODE = Hash[STATUS_CODES.map { |code, msg| [msg.downcase.gsub(/\s|-/, '_').to_sym, code] }]
    SYMBOL_TO_STATUS_CODE.freeze

    attr_reader :status
    attr_reader :headers
    attr_reader :body

    # Status aliases! TIMTOWTDI!!! (Want to be idiomatic? Just use status :)
    alias_method :code,        :status
    alias_method :status_code, :status

    def initialize(status = nil, version = "1.1", headers = {}, body)
      @status, @version, @body = status, version, body

      @headers = {}
      headers.each do |field, value|
        @headers[canonicalize_header(field)] = value
      end
    end

    # Set a header
    def []=(name, value)
      # If we have a canonical header, we're done
      key = name[CANONICAL_HEADER]

      # Convert to canonical capitalization
      key ||= canonicalize_header(name)

      # Check if the header has already been set and group
      old_value = @headers[key]
      if old_value
        @headers[key] = [old_value].flatten << key
      else
        @headers[key] = value
      end
    end

    # Obtain the 'Reason-Phrase' for the response
    def reason
      # FIXME: should get the real reason phrase from the parser
      STATUS_CODES[@status]
    end

    # Get a header value
    def [](name)
      @headers[name] || @headers[canonicalize_header(name)]
    end

    # Returns an Array ala Rack: `[status, headers, body]`
    def to_a
      [status, headers, body.to_s]
    end

    # Inspect a response
    def inspect
      "#<#{self.class}/#{@version} #{status} #{reason} @headers=#{@headers.inspect}>"
    end
  end
end
