require 'net/http'
require 'uri'
require 'thread'

module PerplexityApi
  class ConnectionPool
    def initialize(max_connections: 5, timeout: 30)
      @max_connections = max_connections
      @timeout = timeout
      @connections = {}
      @mutex = Mutex.new
    end

    def get_connection(uri)
      key = "#{uri.host}:#{uri.port}"
      
      @mutex.synchronize do
        # Clean up expired connections
        cleanup_expired_connections
        
        # Get or create connection pool for this host
        @connections[key] ||= []
        pool = @connections[key]
        
        # Try to reuse existing connection
        while pool.size > 0
          connection = pool.pop
          if connection_still_valid?(connection)
            return connection
          end
        end
        
        # Create new connection if pool is empty
        create_connection(uri)
      end
    end

    def return_connection(uri, connection)
      key = "#{uri.host}:#{uri.port}"
      
      @mutex.synchronize do
        @connections[key] ||= []
        pool = @connections[key]
        
        # Only return to pool if we haven't exceeded max connections
        if pool.size < @max_connections && connection_still_valid?(connection)
          connection.instance_variable_set(:@last_used, Time.now)
          pool.push(connection)
        else
          # Close excess connections
          begin
            connection.finish if connection.started?
          rescue => e
            # Ignore errors when closing connections
          end
        end
      end
    end

    private

    def create_connection(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.scheme == 'https'
      http.open_timeout = @timeout
      http.read_timeout = @timeout
      http.instance_variable_set(:@last_used, Time.now)
      http.start
      http
    end

    def connection_still_valid?(connection)
      return false unless connection
      return false unless connection.started?
      
      # Check if connection is too old (30 seconds)
      last_used = connection.instance_variable_get(:@last_used)
      return false if last_used && Time.now - last_used > 30
      
      true
    rescue => e
      false
    end

    def cleanup_expired_connections
      @connections.each do |key, pool|
        pool.reject! do |connection|
          if connection_still_valid?(connection)
            false
          else
            begin
              connection.finish if connection.started?
            rescue => e
              # Ignore errors when closing connections
            end
            true
          end
        end
      end
    end
  end
end