
# Configure neo4j rest api.
# Example: "http://neo4j:swordfish@localhost:7474"

if Rails.env.test?
  Rails.configuration.x.neo4j_rest_url = ENV['NEO4J_REST_URL_TEST'] || raise('expected environment variable NEO4J_REST_URL_TEST')
else
  Rails.configuration.x.neo4j_rest_url = ENV['NEO4J_REST_URL'] || raise('expected environment variable NEO4J_REST_URL')
end

