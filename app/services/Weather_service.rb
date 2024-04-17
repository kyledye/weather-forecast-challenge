require 'httparty'

class WeatherService
  CACHE_EXPIRY = 30.minutes

  def self.fetch(location:, language: 'en', region: 'us', units: 'imperial', exclude: %i[minutely])
    # Halt processing if no location or OPEN_WEATHER_API_KEY value is specified or latitude/longitude don't exist
    return unless location && WEATHER_CONFIG[:api_key] && location.key?(:latitude) && location.key?(:longitude)

    lat = location[:latitude]
    lon = location[:longitude]
    exclude_params = exclude.join(',')

    # Build cache key
    cache_key = build_cache_key(location[:address_components], units)

    # Does the cache key already exist in cache?  If so, return the value and
    # Save some processing time!
    cached_response = Rails.cache.read(cache_key)
    return { results: JSON.parse(cached_response), read_from_cache: true } if cached_response

    # Fetch data from API
    response = fetch_weather_from_api(lat, lon, exclude_params, units)
    results = response.body if response&.success?

    # Cache and return results
    cache_and_return_results(cache_key, results)

  end

  private

  # Since our geolocation tool doesn't always deliver all of the address components required,
  # we have to make a dynamic, complex cache_key, so we work from the outside in, geographcially
  # Example key: weather/us/mi/grand-rapids/49505
  def self.build_cache_key(address_components, units)
    [
      'weather',
      address_components[:country]&.parameterize,
      address_components[:administrative_area_level_1]&.parameterize,
      address_components[:locality]&.parameterize,
      address_components[:postal_code]&.parameterize,
      units
    ].compact.join('/').downcase
  end

  # Capture the data from the OpenWeatherMap.org API
  # Since we include HTTParty at the top of this class, we gain the get method for free (used here)
  def self.fetch_weather_from_api(lat, lon, exclude_params, units)
    api_key = WEATHER_CONFIG[:api_key]
    HTTParty.get("https://api.openweathermap.org/data/3.0/onecall?lat=#{lat}&lon=#{lon}&exclude=#{exclude_params}&units=#{units}&appid=#{api_key}")
  end

  # Cache and update the results to reflect that we didn't read from cache initially
  def self.cache_and_return_results(cache_key, results)
    Rails.cache.fetch(cache_key, expires_in: CACHE_EXPIRY) { results }
    { results: JSON.parse(results), read_from_cache: false }
  end

end