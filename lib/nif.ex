defmodule Teletype.Nif do
  @on_load :init

  def init() do
    nif = :code.priv_dir(:teletype) ++ '/nif'
    :erlang.load_nif(nif, 0)
  end

  def ttypath() do
    ttyname() |> List.to_string()
  end

  def ttyname() do
    :erlang.nif_error("NIF library not loaded")
  end

  def ttyreset() do
    :erlang.nif_error("NIF library not loaded")
  end

  def ttyraw() do
    :erlang.nif_error("NIF library not loaded")
  end

  def ttysignal() do
    :erlang.nif_error("NIF library not loaded")
  end
end
