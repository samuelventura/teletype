defmodule Teletype.Vt do
  def ch(tn) do
    exec = :code.priv_dir(:teletype) ++ '/vt'

    case System.cmd("#{exec}", ["#{tn}"]) do
      {_, 0} -> :ok
      error -> {:error, error}
    end
  end
end
