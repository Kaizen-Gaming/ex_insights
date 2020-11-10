# ExInsights

[![Hex.pm](https://img.shields.io/hexpm/v/ex_insights.svg?style=flat-square&colorB=6e347e)](https://hex.pm/packages/ex_insights)

Elixir client library to log telemetry data on Azure Application Insights.

## Installation

Install from hex by adding `ex_insights` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_insights, "~> 0.8"}
  ]
end
```

You then need to start the `ExInsights.Supervisor` in your supervision tree. Example:

```elixir
# inside the init/1 of some supervisor in your supervision tree (or application.ex)

children = [
  # ...
  {ExInsights.Supervisor, instrumentation_key: "0000-1111-2222-3333"}
]

Supervisor.init(children, strategy: :one_for_one)
```
### Note
For migrating to 0.8.x and later versions read the migration instructions below

## Configuration
ExInsights supports the following configuration options you can set when starting the `ExInsights.Supervisor`

* `:instrumentation_key`: You can set the instrumentation key (Azure App Insights secret key) to use for sending data to Azure. It can be overriden on each `ExInsights.track_xxx` request. Needs to be present either by setting it here or on every request, otherwise the code will raise with an error (string)
* `:flush_inteval_secs`: the number of seconds every which the client will send the telemetry data to Azure. Default is every 30 seconds since the last flushing (non-negative integer)
* `:client_module`: the module to use for actually sending the requests. Mostly useful in tests (atom)

Example:

```elixir
options = [
  instrumentation_key: "0000-1111-2222-3333",
  flush_interval_secs: 30
]

children = [
  # ...
  {ExInsights.Supervisor, options}
]

Supervisor.init(children, strategy: :one_for_one)
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

# log telemetry data about the incoming request processed by the application
ExInsights.track_request("homepage", "http://my.site.com/", "HomePageComponent", 85, 200, true)
```

For more details and optional arguments look at the [`ExInsights`](https://hexdocs.pm/ex_insights/ExInsights.html) module documentation.

### Alternative usage

You can also decorate methods you need to track using [decorators](https://github.com/arjan/decorator).

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

## Migrating from 0.7.x to 0.8.x
In order to make configuring the client more flexible and in accordance to [library development guidelines for configuration](https://hexdocs.pm/elixir/master/library-guidelines.html#avoid-application-configuration), support for configuring the client by setting options directly inside config.exs files was dropped and configuration now needs to happen on supervisor startup.

For example instead of simply doing this inside config.exs
```elixir
# No longer supported
config :ex_insights,
  instrumentation_key: "0000-1111-2222-3333"
```

You now need to pass this option to the `ExInsights.Supervisor` directly instead
```elixir
children = [
  ...
  {ExInsights.Supervisor, instrumentation_key: "0000-1111-2222-3333"}
]
```

If you need to keep reading this value from your config files you can still do
```elixir
# in config.exs
config :my_app, ex_insights_instrumentation_key: "0000-1111-2222-3333"

# in you supervisor.ex file
def read_instrumentation_key_from_config do
  Application.get_env(:my_app, :ex_insights_instrumentation_key)
end

def init(_) do
  ...
  children = [
    # ...
    {ExInsights.Supervisor, instrumentation_key: read_instrumentation_key_from_config()}
  ]
end
```

## Inner workings
* Calling any tracking function `ExInsights.track_xxx` from your code will not immediately send the data to Azure. It will instead be aggregated in memory until the `flush_timer` is triggered (every 30 secs, configurable) and the data will be batch sent.
* When the application shuts down it will attempt to flush any remaining data.
* If you are behind a firewall (usually happens in production deployments) make sure your network rules **allow HTTP POSTs to https://dc.services.visualstudio.com**
* If requests to azure tracking services fail (network or server errors or bad requests) you will not be alerted.
* `track_dependency` and `track_exception` decorators will try to `rescue`/`catch` any errors (and log those) and then re-raise the error / exit as appropriate. This is a different (but hopefully working) approach than what the AppSignal guys do (a separate process monitoring crashes)
