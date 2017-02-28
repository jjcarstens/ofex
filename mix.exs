defmodule Ofex.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ofex,
      name: "Ofex",
      description: "A simple parser for Open Financial Exchange (OFX) data in elixir",
      version: "0.1.6",
      elixir: "~> 1.4",
      package: [
        maintainers: ["Jon Carstens"],
        licenses: ["MIT"],
        links: %{
          "GitHub" => "https://github.com/jjcarstens/ofex"
        }
      ],
      deps: deps(),
      source_url: "https://github.com/jjcarstens/ofex",
      docs: [main: "Ofex", extras: ["README.md"]]
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:credo, ">= 0.0.0", only: [:dev, :test]},
      {:ex_doc, "~> 0.14", only: :dev, runtime: false},
      {:sweet_xml, "~> 0.6"},
      {:timex, "~> 3.0"},
    ]
  end
end
