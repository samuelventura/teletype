defmodule Teletype.Pts do
  def open(opts \\ []) do
    tty = Keyword.get_lazy(opts, :tty, &Teletype.Nif.ttypath/0)
    exec = :code.priv_dir(:teletype) ++ '/pts'
    opts = [:binary, :exit_status, :stream, args: [tty]]
    Port.open({:spawn_executable, exec}, opts)
  end

  def close(port) do
    Port.close(port)
  end

  def read!(port) do
    receive do
      {^port, {:data, data}} ->
        data

      any ->
        raise "#{inspect(any)}"
    end
  end

  def write!(port, data) do
    true = Port.command(port, data)
  end
end
