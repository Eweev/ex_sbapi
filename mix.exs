defmodule ExSbapi.Mixfile do
  use Mix.Project

  @version "0.1.26"
  @name "shopbuilder_api"
  @maintainers ["Julien Fayad"]
  @url "https://github.com/Eweev/ex_sbapi"

  def project do
    [
      app: :ex_sbapi,
      version: @version,
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      name: @name,
      source_url: @url
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about depmiendencies.
  defp deps do
    [
      {:oauth2, "~> 0.9"},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:credo, "~> 0.10.0", only: [:dev, :test], runtime: false},
      {:inch_ex, github: "rrrene/inch_ex", only: [:dev, :test], runtime: false},
      {:poison, "~> 3.1"},
      # Optional
      {:plug, "~> 1.3.3 or ~> 1.4", optional: true}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end

  defp description() do
    "Elixir Wrapper Around the ShopBuilder API"
  end

  defp package() do
    [
      # This option is only needed when you don't want to use the OTP application name 
      name: @name,
      # These are the default files included in the package 
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: @maintainers,
      licenses: ["MIT"],
      links: %{"GitHub" => @url}
    ]
  end
end
