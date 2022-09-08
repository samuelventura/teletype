defmodule Teletype do
  def chvt(tn) do
    exec = :code.priv_dir(:teletype) ++ '/chvt'
    System.cmd("#{exec}", ["#{tn}"])
  end
end
