RSpec.describe WeatherService do
  describe '.fetch' do
    context 'when location and API key are provided' do
      let(:location) { { latitude: 40.7128, longitude: -74.0060, address_components: { country: 'US', administrative_area_level_1: 'NY', locality: 'New York', postal_code: '10001' } } }
      let(:units) { 'imperial' }

      it 'returns weather data' do
        VCR.use_cassette('weather_fetch') do
          expect(WeatherService.fetch(location: location)).to include(
            :results,
            :read_from_cache
          )
        end
      end
    end

    context 'when location or API key is missing' do
      it 'returns nil' do
        expect(WeatherService.fetch(location: nil)).to be_nil
      end
    end
  end

  describe '.build_cache_key' do
    it 'builds the cache key correctly' do
      address_components = {
        country: 'US',
        administrative_area_level_1: 'NY',
        locality: 'New York',
        postal_code: '10001'
      }
      units = 'imperial'

      cache_key = WeatherService.send(:build_cache_key, address_components, units)

      expect(cache_key).to eq('weather/us/ny/new-york/10001/imperial')
    end
  end

  describe '.cache_and_return_results' do
    it 'caches the weather data and returns the results' do
      cache_key = 'weather_cache_key'
      results = '{"temperature": 25, "humidity": 70}'

      expect(Rails.cache).to receive(:fetch).with(cache_key, expires_in: WeatherService::CACHE_EXPIRY).and_yield

      expect(WeatherService.send(:cache_and_return_results, cache_key, results)).to eq(
        results: JSON.parse(results),
        read_from_cache: false
      )
    end
  end
end
