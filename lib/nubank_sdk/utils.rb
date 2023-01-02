# frozen_string_literal: true

module NubankSdk
  #
  # Utils
  module Utils
    #
    # read graphQL query from file in ../graphql/{path}/{query}.gql
    #
    # @param [String] path - path to the query account, credit
    # @param [String] query - query name
    #
    # @return [String]
    def self.read_graphql_query(path, query)
      File.read(File.join('.', 'lib', 'graphql', path, "#{query}.gql"))
    end
  end
end
