# ExInsights

Elixir client library to log telemetry data on Azure Application Insights.

## Installation

Install from hex by adding `ex_insights` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_insights, "~> 0.1.0"}
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

If you forget to set the key the application will `raise` with an appropriate message anytime an `ExInsights.track_xxx` function is used

## Usage
All public tracking methods are under the `ExInsights` module. Examples:

```elixir
# will post a click custom_event to azure
ExInsights.track_event("click")

# with custom defined property "type" and measurement "count"
ExInsights.track_event("click", %{type: "button"}, %{count: 2})

# send custom metric data. Does not support aggregated data (count/stdDev, min, max)
ExInsights.track_metric("bananas", 10)
```

For more details look at the [`ExInsights`](https://hexdocs.pm/ex_insights/ExInsights.html) module documentation.

## Inner workings
* Calling any tracking function `ExInsights.track_xxx` from your code will not immediately send the data to Azure. It will instead be aggregated in memory until the `flush_timer` is triggered (every 60 secs) and the data will be batch sent.
* If you are behind a firewall (usually happens in production deployments) make sure your network rules **allow HTTP POSTs to https://dc.services.visualstudio.com**
* If requests to azure tracking services fail (network or server errors or bad requests) you will not be alerted.
