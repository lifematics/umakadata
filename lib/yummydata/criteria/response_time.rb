require 'yummydata/http_helper'
require 'sparql/client'
require 'rdf/turtle'

module Yummydata
  module Criteria
    module ResponseTime

      # include Yummydata::HTTPHelper

      def prepare(uri)
        @client = SPARQL::Client.new(uri, {'read_timeout': 5 * 60}) if @uri == uri && @client == nil
        @uri = uri
      end

      def response_time(uri)
        self.prepare(uri)

        ask_query = <<-'SPARQL'
ASK{}
SPARQL
        ask_response_time = self.get_response_time(ask_query)

        target_query = <<-'SPARQL'
SELECT DISTINCT
  ?g
WHERE {
  GRAPH ?g {
    ?s ?p ?o
  }
}
SPARQL

        target_response_time = self.get_response_time(target_query)
        if ask_response_time.nil? || target_response_time.nil?
          return nil
        end

        response_time = target_response_time - ask_response_time
        response_time >= 0.0 ? response_time : nil
      end

      def get_response_time(sparql_query)
        begin
          start_time = Time.now

          @client.query(sparql_query)

          end_time = Time.now
        rescue => e
          return nil
        end

        end_time - start_time
      end

    end
  end
end
