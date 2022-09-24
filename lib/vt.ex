defmodule Teletype.Vt do
  def ch(tn) do
    exec = :code.priv_dir(:teletype) ++ '/tty'
    {_, 0} = System.cmd("#{exec}", ["#{tn}"])
  end
end
