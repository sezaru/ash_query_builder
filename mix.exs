defmodule AshQueryBuilder.MixProject do
  use Mix.Project

  @app :ash_query_builder
  @name "AshQueryBuilder"
  @description "A simple query builder helper for Ash.Query"
  @version "0.4.1"
  @github "https://github.com/sezaru/#{@app}"
  @author "Eduardo Barreto Alexandre"
  @license "MIT"

  def project do
    [
      app: @app,
      version: @version,
      elixir: "~> 1.14",
      name: @name,
      description: @description,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      package: package(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: preferred_cli_env()
    ]
  end

  def application, do: [extra_applications: [:logger]]

  defp deps do
    [
      {:ex_doc, "~> 0.29", only: [:dev, :docs], runtime: false},
      {:excoveralls, "~> 0.16", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.3", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:ash, "~> 2.6"},
      {:memoize, "~> 1.4"}
    ]
  end

  defp docs do
    [
      main: "readme",
      source_ref: "v#{@version}",
      source_url: @github,
      extras: [
        "README.md"
      ]
    ]
  end

  defp package do
    [
      name: @app,
      maintainers: [@author],
      licenses: [@license],
      links: %{"Github" => @github}
    ]
  end

  defp preferred_cli_env do
    [
      coveralls: :test,
      "coveralls.detail": :test,
      "coveralls.post": :test,
      "coveralls.html": :test
    ]
  end
end
