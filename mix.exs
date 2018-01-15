defmodule ExSbapi.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ex_sbapi,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      name: "ShopBuilder API",
      source_url: "https://github.com/Eweev/ex_sbapi" 
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:oauth2, "~> 0.9"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end
  defp description() do 
    "Elixir Wrapper Around the ShopBuilder API" 
  end 

  defp package() do 
    [ 
      organization: "Eweev", 
      # This option is only needed when you don't want to use the OTP application name 
      name: "ShopBuilder API",
      # These are the default files included in the package 
      files: ["lib", "priv", "mix.exs", "README*", "readme*", "LICENSE*", "license*"], 
      maintainers: ["Julien Fayad","Jad Tarabay"], 
      licenses: ["Shopbuilder"],
      links: %{"GitHub" => "https://github.com/Eweev/ex_sbapi"}
    ] 
  end 

end