RSpec.describe GeocodingService do
  describe '.search' do
    let(:address) { '1 Apple Park Way, Cupertino, CA' }
    let(:address_no_postal_code) { 'Grand Rapids, MI' }
    let(:address_no_result) { 'asdjflasjd f;jsadl;fj lsdjfl sjdfl;ajsdfl;j' }
    let(:language) { 'en' }
    let(:region) { 'us' }
    let(:cassette_name) { 'geocoding_search' }
    let(:cassette_name_no_postal_code) { 'geocoding_search_no_postal_code' }
    let(:cassette_name_empty_result) { 'geocoding_search_empty_result' }
    let(:cassette_name_nil_result) { 'geocoding_search_nil_result' }

    it 'returns the expected geocoding data' do
      VCR.use_cassette(cassette_name) do
        expect(GeocodingService.search(address: address, language: language, region: region)).to eq({
          address_components: {
            locality: 'Cupertino',
            administrative_area_level_1: 'CA',
            administrative_area_level_2: 'Santa Clara County',
            country: 'US',
            postal_code: '95014',
            postal_code_suffix: '0642',
            route: 'Apple Park Way',
            street_number: '1',
          },
          display_location: 'Cupertino, CA, 95014',
          formatted_address: '1 Apple Park Way, Cupertino, CA 95014, USA',
          latitude: 37.3293917,
          longitude: -122.0084085
        })
      end
    end

    it 'returns results without a postal_code' do
      VCR.use_cassette(cassette_name_no_postal_code) do
        expect(GeocodingService.search(address: address_no_postal_code, language: language, region: region)).to eq({
          address_components: {
            locality: 'Grand Rapids',
            administrative_area_level_1: 'MI',
            administrative_area_level_2: 'Kent County',
            country: 'US',
          },
          display_location: 'Grand Rapids, MI',
          formatted_address: 'Grand Rapids, MI, USA',
          latitude: 42.9633599,
          longitude: -85.6680863,
        })
      end
    end

    it 'returns no result with bad address' do
      VCR.use_cassette(cassette_name_empty_result) do
        expect(GeocodingService.search(address: address_no_result, language: language, region: region)).to be nil
      end
    end

    it 'returns no result with empty address' do
      VCR.use_cassette(cassette_name_nil_result) do
        expect(GeocodingService.search(address: nil, language: language, region: region)).to be nil
      end
    end
  end
end
