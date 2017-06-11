defmodule Vector.Mixfile do
  use Mix.Project

  def project do
    [app: :vector,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [{:dialyxir, "~> 0.5", only: :dev, runtime: false},
     {:ex_doc, ">= 0.0.0", only: :dev},
     {:benchee, "~> 0.9.0", only: :dev}]
  end
end
