# frozen_string_literal: true

module ParsedJson
  def json
    JSON.parse(response.body)
  end
end

RSpec.configure do |config|
  config.include ParsedJson, type: :request
  config.include ParsedJson, type: :service
end
