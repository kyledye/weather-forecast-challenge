# Weather Forecasting App

The weather forecasting app is crafted to provide users with lightning-fast and detailed weather information. It achieves this by harnessing the power of third-party APIs and employing proven development patterns.

## Installation

This application was built using Ruby v. 3.2.2, Ruby on Rails 7.1.3.2, and SQLite. For detailed instructions on how to install Ruby on Rails and SQLite on your specific operating system, please refer to this comprehensive guide created by GoRails: GoRails Setup Guide.

Once you have Rails set up on your machine and the repository has been checked out from GitHub, run the following command from within the project's root directory using your preferred terminal:

This application was built using Ruby v. 3.2.2, Ruby on Rails 7.1.3.2, and SQLite.  For a great reference of how to install Ruby on Rails and SQLite on your specific operating system, please check out this amazing guide created by [GoRails](https://gorails.com/setup/macos/14-sonoma)

One you have Rails setup on your machine and the repository has been checked out from GitHub, run the following command from within the project root directory, using your favorite terminal:

```console
bundle install
```

This will install all dependencies defined in the Gem file and will allow you to begin testing locally.

## Getting Started

To check out the project locally in your browser, navigate to the project root directory from within your terminal and run the following command:

```console
bin/rails server
```

The output will look similar to the following:

```console
kdye@white-lightning:~/Sites/WeatherForcaster$ bin/rails server
=> Booting Puma
=> Rails 7.1.3.2 application starting in development 
=> Run `bin/rails server --help` for more startup options
Puma starting in single mode...
* Puma version: 6.4.2 (ruby 3.2.2-p53) ("The Eagle of Durango")
*  Min threads: 5
*  Max threads: 5
*  Environment: development
*          PID: 299743
* Listening on http://127.0.0.1:3000
```

Depending on the terminal app you're using, you can either click on the Listening URL to open it in your browser or manually navigate to it in your browser.

## Toggling Cache for Development Environment

By default, caching is enabled for the weather forecasting app in the development environment. You can modify the value of `config.action_controller.perform_caching` to either `true` (enabled) or `false` (disabled). Alternatively, you can use the following command-line toggler:
```console
rails dev:cache
```

## Running Tests

The weather forcasting app uses RSpec for unit testing, so running tests are as easy as running the following command from within your project in a terminal:

```console
rspec spec
```

When the testing suite completes, a coverage report will be generated in the `coverage/` directory within the project and you can open it in any web browser.

## Service Objects

There are two service objects used in this application, both are located in `app/services/` and are wrappers around third-party APIs.

### Geocoding Service

The Geocoding Service allows us the ability to parse the user's intended search string into an address object.

#### Public Interface

The `self.search` method serves as our primary public interface. It accepts an `address` argument as a string, along with optional `language` (defaults to `en`) and `region` (defaults to `us`) arguments to support future enhancements. We utilize the `geocoder` ruby gem and its default configurations to make these requests, and we call the Google Maps API for our results.

#### Handling Undefined Addresses

If an address is not defined, the method will instantly return a nil value, saving processing ticks.

#### Caching and Expiry

We employ a 30-day cache expiry on API calls within this service. The logic behind this is to save on calls to the Google API service, as locations are not generally updated frequently.

#### Returned Object

When a successful call occurs, an object will be returned containing:

- Address components such as country, locality (city), postal_code
- Display location: Typically represented as something like "Grand Rapids, MI, 49505" or "Beverly Hills, CA, 90210"
- Formatted Address: A formally normalized address provided by Google
- Latitude
- Longitude

Latitude and longitude are vital for accurate forecasts in our Weather Service.

### Weather Service

The Weather Service acts as a wrapper for fetching current weather and extended forecasts using the OpenWeatherMaps.org API.

#### Public Interface

The primary method, `self.fetch`, serves as our main public interface. It accepts a `location` object from the Geocoding Service, along with optional parameters such as `language`, `region`, `units`, and `exclude`. These parameters are customizable and adhere to the values defined in the OpenWeatherMaps.org API contract. We utilize HTTParty for making the get request. Our API KEY is stored in `config/initializers/weather.rb` for easy configuration.

#### Handling Undefined Addresses

If the location object is not defined or lacks latitude and longitude information, the service will promptly return a nil response. Additionally, if the `api_key` value is not set in the initializer file, it will also return nil.

#### Caching and Expiry

To enhance user experience and reduce unnecessary API calls, we implement a 30-minute cache expiry mechanism within this service.

#### Returned Object

Upon a successful call, the service returns an object containing:

- A `results` object with the contract response from OpenWeatherMaps.org.
- A `read_from_cache` boolean value indicating whether the data was retrieved from the cache (true) or a call was made to the third-party API (false).

## Forecast Controller

In this one-page application, we have a single controller located at `app/controllers/forecast_controller.rb`, which also serves as the root controller. This controller is responsible for three main operations:

1. **Capturing User Query**: It retrieves the user query from `params[:q]`.
2. **Geocoding Service Interaction**: It forwards the query to the Geocoding Service for analysis.
3. **Weather Service Interaction**: It passes the geocoded address to the Weather Service to obtain forecast details.

## Forecast Views - `app/views/forecast`

### `_alerts.html.erb`

If there is an alert to display, we will show it in this partial.

We display this alert as a Twitter Bootstrap alert component with a danger class. This is to alert the user of any announcements made, typically by the National Weather Service (NWS).

Currently, we only support displaying the latest alert. However, we should consider improving the logic of this component to support more complicated objects.

### `_cache_tag.html.erb`

The `cache_tag` partial indicates to the user whether or not the data being displayed was read from cache.

This information is not intended to be critical, so it is displayed in a muted style.

A `read_from_cache` boolean argument needs to be passed into it in order to display the proper `I18n` translated message.

### `_current_temperature.html.erb`

This partial displays basic current weather data and location information, providing users with a quick update. It accepts the following arguments:

- **location:** A geolocation object passed from the `GeocodingService`.
- **forecast:** A valid weather forecast object passed from the `WeatherService`.
- **time:** A localized time string generated in `index.html.erb`.
- **high_temp:** A high temperature number generated and rounded in `index.html.erb`.
- **low_temp:** A low temperature number generated and rounded in `index.html.erb`.

### `_extended_forecast.html.erb`

The extended forecast partial presents a table-based view of the weather for the upcoming days based on the given postal code. It accepts the following arguments:

- **location:** A geolocation object passed from the `GeocodingService`.
- **forecast:** A valid weather forecast object passed from the `WeatherService`.

### `_no_results.html.erb`

This partial view will display a generic, `I18n` translated message to the user to guide them along their search path.  It will display only if:

- No query has been defined
- No results were found for that query.

### `_search_form.html.erb`

The search form is always visible as the primary location for user input in the application. If a query is defined in the query parameters, it will be pre-filled into the input box and trigger the main search functionality. If no value is set, it will display a translated placeholder. The button to submit the form serves as the primary Call to Action (CTA) for the user.

### `_weather_today.html.erb`

The "Weather Today" partial displays current weather details and is the most complex partial view in the app. It accepts the same arguments as the `_current_temperature.html.erb` partial:

- **location:** A geolocation object passed from the `GeocodingService`.
- **forecast:** A valid weather forecast object passed from the `WeatherService`.
- **time:** A localized time string generated in `index.html.erb`.
- **high_temp:** A high temperature number generated and rounded in `index.html.erb`.
- **low_temp:** A low temperature number generated and rounded in `index.html.erb`.

Additional calculations are required to display the data correctly:

1. Visibility is converted from kilometers to miles by multiplying the provided value by 0.000621371 and rounded for readability.
2. Barometric pressure is calculated by converting the provided hectopascals (hPA) value into inches of mercury (inHg) by multiplying the pressure value by the conversion factor 0.029529983071445 and rounding for readability.
3. Sunrise and sunset are localized to the proper timezone and formatted to display properly.

### `index.html.erb`

This is the main view for the app. It controls the display logic and includes partials when necessary.

- The search form at the top will always be displayed to the user.
- If there is a forecast object to display to the user, it will show:
  - Urgent alerts
  - Current temperature information
  - Weather details (i.e., visibility, humidity, barometric pressure, etc.)
  - An extended forecast (if available).
- If there is not a forecast object to display, a blue alert will display to guide the user.
- At the bottom of the page, the user will be notified as to whether or not the data was read from cache.
