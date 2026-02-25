defmodule HopperKino.MixProject do
  use Mix.Project

  def project do
    [
      app: :hopper_kino,
      version: "0.1.0",
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:kino, "~> 0.14"},
      {:hopper, path: ".."}
    ]
  end
end
