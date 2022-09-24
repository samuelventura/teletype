defmodule Teletype.MixProject do
  use Mix.Project

  def project do
    [
      app: :teletype,
      version: "0.1.0",
      elixir: "~> 1.13",
      make_clean: ["clean"],
      compilers: [:elixir_make | Mix.compilers()],
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:elixir_make, "~> 0.6", runtime: false},
      {:erlexec, "~> 1.0", only: [:dev, :test], runtime: false}
    ]
  end

  defp description do
    "Elixir TTY/PTY native ports."
  end

  defp package do
    [
      name: :teletype,
      files: ["lib", "test", "src", "exs", "mix.*", "*.exs", "*.md", ".gitignore", "LICENSE"],
      maintainers: ["Samuel Ventura"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/samuelventura/teletype/"}
    ]
  end
end
