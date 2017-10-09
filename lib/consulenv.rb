require "json"
require "net/http"
require "base64"

module Consulenv
  class ConsulError < StandardError
  end

  INSTRUCTIONS_PER_TRANSACTION = 64

  class << self
    def load(settings)
      results = read_from_consul(settings.keys)
      settings.each do |consul_key, env_key|
        ENV[env_key] = results.fetch(consul_key)
      end
    end

    private

    def read_from_consul(keys)
      all = {}
      keys.each_slice(INSTRUCTIONS_PER_TRANSACTION) do |slice|
        query = slice.map { |key| {"KV" => {"Verb" => "get", "Key" => key}} }
        results = put("/v1/txn", query).fetch("Results")
        results.each do |result|
          reply = result.fetch("KV")
          all[reply.fetch("Key")] = deserialize_value(reply.fetch("Value"))
        end
      end
      all
    end

    def deserialize_value(value)
      value == "null" ? nil : Base64.decode64(value)
    end

    def put(path, query)
      host, port = ENV.fetch("CONSUL_HTTP_ADDR", "localhost:8500").split(":", 2)
      request = Net::HTTP::Put.new(path, 'Content-Type' => 'application/json')
      request.body = query.to_json
      response = Net::HTTP.new(host, port).start { |http| http.request(request) }
      raise ConsulError, "Consul request failed: #{response.body}" unless response.is_a?(Net::HTTPOK)
      JSON.parse(response.body)
    end
  end
end
