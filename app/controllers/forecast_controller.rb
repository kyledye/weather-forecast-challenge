class ForecastController < ApplicationController
  def index
    @query = params[:q]
    @geolocation = geocode_address(@query)
    @forecast = fetch_weather(@geolocation) if @geolocation
  end

  private

  def geocode_address(address)
    return unless address.present?
    GeocodingService.search(address: @query)
  end

  def fetch_weather(geolocation)
    WeatherService.fetch(location: geolocation)
  end

end
