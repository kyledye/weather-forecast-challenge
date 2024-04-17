class GeocodingService
  CACHE_EXPIRY = 30.days

  def self.search address:, language: 'en', region: 'us'
    # Stop processing immediately if no address is specified
    return unless address

    # Including the language and region parameters in the cache key to ensure
    # that results are cached separately for different language and region combinations.
    cache_key = "geocoding/#{address.parameterize}/#{language}/#{region}"

    # Retreive results from cache or perform geocoding lookup
    results = Rails.cache.fetch(cache_key, expires_in: CACHE_EXPIRY) do
      geocoder_search(address, language, region)
    end

    # Return nil if no results are found
    return unless results

    # Extract address components
    address_components = extract_address_components(results)

    {
      address_components: address_components,
      display_location: display_location(address_components),
      formatted_address: results['formatted_address'],
      latitude: results.dig('geometry', 'location', 'lat'),
      longitude: results.dig('geometry', 'location', 'lng')
    }
  end

  # Moved the geocoder search logic into a separate method to improve
  # readability and maintainability.  The method returns only the data
  # attribute of the final result.
  def self.geocoder_search(address, language, region)
    # Avoiding unnecessary method calls by directly accessing the data attribute
    # of the geocoding results
    result = Geocoder.search(address, { language: language, region: region }).first
    result.data if result # Access .data only if result is not nil
  end

  # Simplified the method by directly accessing the required address components
  # and using compact+join to remove nil values and concatenate the components
  # into a single string.
  def self.display_location(results)
    loc = [results.dig(:locality), results.dig(:administrative_area_level_1), results.dig(:postal_code)]
    loc.compact.join(', ')
  end

  def self.extract_address_components(data)
    # Simplify address component extraction using transform_values
    return {} unless data['address_components']

    data['address_components'].each_with_object({}) do |ac, components|
      components[ac['types'][0].to_sym] = ac['short_name']
    end
  end

end