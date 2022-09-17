defmodule Teletype do
  alias Teletype.Nif

  def chvt(tn) do
    exec = :code.priv_dir(:teletype) ++ '/tty'
    {_, 0} = System.cmd("#{exec}", ["#{tn}"])
  end

  def name(), do: Nif.ttyname()
  def raw(), do: Nif.ttyraw()
  def reset(), do: Nif.ttyreset()
  def signal(), do: Nif.ttysignal()
end
