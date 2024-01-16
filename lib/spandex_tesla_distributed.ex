defmodule SpandexTeslaDistributed do
  @moduledoc """
  Add trace metadata to properly handle distributed tracing.

  ## Example
  ```
  defmodule MyClient do
    use Tesla

    plug SpandexTeslaDistributed, tracer: YourApp.Tracer
  end
  ```

  ## Options

  - `:tracer` - optional - Spandex.Tracer instance to use
  """
  defmodule Error do
    @moduledoc """
    Struct used to identify the errors.
    """
    defexception [:message]
  end

  @behaviour Tesla.Middleware

  @impl Tesla.Middleware
  def call(env, next, opts) do
    opts = opts || []
    tracer = Keyword.get(opts, :tracer, tracer())

    case tracer.current_context() do
      {:ok, _tracer_ctx} ->
        upcased_method = env.method |> to_string() |> String.upcase()

        tracer.start_span("request",
          service: service(),
          resource: "#{upcased_method} #{env.url}",
          type: :web,
          http: [
            url: env.url,
            method: upcased_method
          ]
        )

        headers = tracer.inject_context([])

        try do
          case Tesla.run(Tesla.put_headers(env, headers), next) do
            {:ok, env} ->
              case env.status do
                status when status not in 200.299 ->
                  tracer.update_span(http: [status_code: env.status])
                  tracer.span_error(%Error{message: "Request failed with status response #{env.status}"})
                  {:ok, env}
                _ ->
                  tracer.update_span(http: [status_code: env.status])
                  {:ok, env}

            {:error, reason} = e ->
              tracer.span_error(%Error{message: inspect(reason)}, nil, [])

              e
          end
        catch
          kind, reason ->
            stacktrace = System.stacktrace()
            tracer.span_error(%Error{message: inspect(reason)}, nil, [])
            tracer.finish_span()

            :erlang.raise(kind, reason, stacktrace)
        after
          tracer.finish_span()
        end

      {:error, _reason} ->
        Tesla.run(env, next)
    end
  end

  defp tracer do
    Application.fetch_env!(:spandex_tesla_distributed, :tracer)
  end

  defp service do
    Application.get_env(:spandex_tesla_distributed, :service, :tesla)
  end
end
