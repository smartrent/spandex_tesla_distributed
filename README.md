# SpandexTeslaDistributed

Tesla Middleware for Spandex that supports distributed tracing

## Installation
```elixir
def deps do
  [
    {:spandex_tesla_distributed, github: "smartrent/spandex_tesla_distributed", tag: "0.3.0"}
  ]
end
```

Add the following to your `config.exs` where YourApp.Tracer is your implementation of the Spandex.Tracer
```elixir
config :spandex_tesla_distributed,
  service: :your_app_tesla,
  tracer: YourApp.Tracer
```

Usage:  It's recommended to have `SpandexTeslaDistributed` as the first middleware in your request.
```elixir
Tesla.client([
  # SpandexTeslaDistributed should come before the Timeout middleware as that creates an async process which loses the trace context
  {SpandexTeslaDistributed, []},
  {Tesla.Middleware.Timeout, [timeout: timeout]}
])
```

or as a Plug
```elixir
  defmodule MyClient do
    use Tesla

    plug SpandexTeslaDistributed, tracer: YourApp.Tracer
  end
```
