defmodule Teletype do
  alias Teletype.Nif

  def chvt(tn) do
    exec = :code.priv_dir(:teletype) ++ '/tty'
    {_, 0} = System.cmd("#{exec}", ["chvt", "#{tn}"])
  end

  # c lang ttyname() fails from within the beam
  # priv/tty name works from bash
  def name() do
    exec = :code.priv_dir(:teletype) ++ '/tty'
    IO.inspect(exec)

    case System.cmd("#{exec}", ["name"]) do
      {ttyname, 0} -> {:ok, ttyname}
      {so, ec} -> {:error, {so, ec}}
    end
  end

  def raw(ttyname \\ nil) do
    exec = :code.priv_dir(:teletype) ++ '/tty'

    args =
      case ttyname do
        nil -> ["raw", Nif.ttypath()]
        _ -> ["raw", "#{ttyname}"]
      end

    case System.cmd("#{exec}", args) do
      {_, 0} -> :ok
      {so, ec} -> {:error, {so, ec}}
    end
  end

  def reset(ttyname \\ nil) do
    exec = :code.priv_dir(:teletype) ++ '/tty'

    args =
      case ttyname do
        nil -> ["reset", Nif.ttypath()]
        _ -> ["reset", "#{ttyname}"]
      end

    case System.cmd("#{exec}", args) do
      {_, 0} -> :ok
      {so, ec} -> {:error, {so, ec}}
    end
  end
end
