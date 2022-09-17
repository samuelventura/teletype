defmodule Teletype do
  def chvt(tn) do
    exec = :code.priv_dir(:teletype) ++ '/tty'
    System.cmd("#{exec}", ["chvt", "#{tn}"])
  end

  def raw(ttyname) do
    exec = :code.priv_dir(:teletype) ++ '/tty'
    System.cmd("#{exec}", ["raw", "#{ttyname}"])
  end

  def reset(ttyname) do
    exec = :code.priv_dir(:teletype) ++ '/tty'
    System.cmd("#{exec}", ["reset", "#{ttyname}"])
  end
end
