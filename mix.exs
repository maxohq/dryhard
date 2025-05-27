defmodule Dryhard.MixProject do
  use Mix.Project

  @github_url "https://github.com/maxohq/dryhard"
  @version "0.1.2"

  def project do
    [
      app: :dryhard,
      description: "Dryhard - Yippee-Ki-Yay, ...wet code!",
      version: @version,
      source_url: @github_url,
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      package: package()
    ]
  end

  def elixirc_paths(:test), do: ["lib", "test/support"]
  def elixirc_paths(_), do: ["lib"]

  defp aliases do
    [
      setup: ["ecto.create --quiet", "ecto.migrate"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Dryhard.Application, []}
    ]
  end

  defp package do
    [
      files: ~w(lib mix.exs README* CHANGELOG*),
      licenses: ["MIT"],
      links: %{
        "GitHub" => @github_url,
        "CHANGELOG" => "https://github.com/maxohq/dryhard/blob/main/CHANGELOG.md"
      }
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto_sql, "~> 3.10"},
      {:postgrex, ">= 0.0.0"},
      {:query_builder, "~> 1.4"},
      {:ex_doc, "~> 0.29", only: :dev, runtime: false},
      {:ex_machina, "~> 2.7", only: [:dev, :test]},
      {:maxo_test_iex, "~> 0.1", only: :test}
    ]
  end
end
