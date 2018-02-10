# ExSbapi

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_sbapi` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_sbapi, "~> 0.1.2", hex: :shopbuilder_api}
  ]
end
```

If you want to validate user sessions for apps using the ShopBuilder JS SDK, you have to 
initialize the process that handles this verification by adding the following line in your `application.ex` children array:

```elixir
supervisor(ExSbapi.Process.SessionSupervisor, [])
```

And protect the routes to secure with the `ExSbapi.Session` Plug.

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/ex_sbapi](https://hexdocs.pm/ex_sbapi).

