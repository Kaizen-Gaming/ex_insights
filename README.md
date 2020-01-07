# ExInsights

[![Hex.pm](https://img.shields.io/hexpm/v/ex_insights.svg?style=flat-square&colorB=6e347e)](https://hex.pm/packages/ex_insights)

Elixir client library to log telemetry data on Azure Application Insights.

## Installation

Install from hex by adding `ex_insights` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_insights, "~> 0.4"}
  ]
end
```

#### Note:
The library is packaged as an application. In `elixir <= 1.3.x` you will need to add it explicitly to the list of
applications started before your own inside `mix.exs` like this:

```elixir
# This step is only required for older elixir installations
def application do
  [
    applications: [:ex_insights]
  ]
end
```

## Configuration

#### Instrumentation key
You need at the very least to set your instrumentation key in order to start accepting telemetry requests
on azure. You can do this by setting the `instrumentation_key` property like this:

```elixir
config :ex_insights,
  instrumentation_key: "0000-1111-2222-3333"
```

You can also use an environment variable instead if that's your preference

```elixir
config :ex_insights,
  instrumentation_key: {:system, "INSTRUMENTATION_KEY"}
# at runtime the application will look for the INSTRUMENTATION_KEY environment variable
```

If you forget to set the key the application will `raise` with an appropriate message anytime an `ExInsights.track_xxx` function is used.

#### Flush interval
You can also set the flush interval in seconds (ie the interval at which data will be sent over to azure). The default is `30 seconds`.

```elixir
config :ex_insights,
  flush_interval_secs: 30
```

## Usage

### Basic Usage

All public tracking methods are under the `ExInsights` module. Examples:

```elixir
# will post a click custom_event to azure
ExInsights.track_event("click")

# with custom defined property "type" and measurement "count"
ExInsights.track_event("click", %{type: "button"}, %{count: 2})

# send custom metric data. Does not support aggregated data (count/stdDev, min, max)
ExInsights.track_metric("bananas", 10)

# log arbitrary data
ExInsights.track_trace("1-2-3 boom", :warning)

# log time taken for requests to external resources, eg. database or http service calls
ExInsights.track_dependency("get_user_balance", "http://my.api/get_balance/aviator1", 1500, true, "user", "my.api")

# log telemetry data about the incoming request processsed by the application
ExInsights.track_request("homepage", "http://my.site.com/", "HomePageComponent", 85, 200, true)
```

For more details and optional arguments look at the [`ExInsights`](https://hexdocs.pm/ex_insights/ExInsights.html) module documentation.

### Advanced usage

Even though you can call `ExInsights.track_xxx` methods directly, the recommended way to use the library is by decorating methods you need to track using [decorators](https://github.com/arjan/decorator).

```elixir
# Make sure to add the following line before using any decorators
use ExInsights.Decoration.Attributes

# add the @decorate track_xxx() attribute right above each function you need to track

@decorate track_event() # will log the "update_user_email" event in AppInsights on funtion entry
def update_user_email(email, user) do
  # ...
end

@decorate track_dependency("user-actions") # put under dependency type:user-actions in AppInsights UI
def login_user(user) do
  # ... maybe call external api here
end

@decorate track_exception() # will track errors and exits
def dangerous_stuff do
  # ... do work that may fail
end
```

## Inner workings
* Calling any tracking function `ExInsights.track_xxx` from your code will not immediately send the data to Azure. It will instead be aggregated in memory until the `flush_timer` is triggered (every 30 secs, configurable) and the data will be batch sent.
* When the application shuts down it will attempt to flush any remaining data.
* If you are behind a firewall (usually happens in production deployments) make sure your network rules **allow HTTP POSTs to https://dc.services.visualstudio.com**
* If requests to azure tracking services fail (network or server errors or bad requests) you will not be alerted.
* `track_dependency` and `track_exception` decorators will try to `rescue`/`catch` any errors (and log those) and then reraise the error / exit as appropriate. This is a different (but hopefully working) approach than what the AppSignal guys do (a separate process monitoring crashes)
