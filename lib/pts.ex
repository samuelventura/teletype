defmodule Teletype.Pts do
  alias Teletype.Nif

  def open(opts \\ []) do
    nif = Nif.ttypath()
    tty = Keyword.get(opts, :tty, nif)
    exec = :code.priv_dir(:teletype) ++ '/pts'
    opts = [:binary, :exit_status, :stream, args: [tty]]
    port = Port.open({:spawn_executable, exec}, opts)
    if tty == nif, do: Nif.ttysignal()
    {port, tty == nif}
  end

  def read!({port, _}) do
    receive do
      {^port, {:data, data}} ->
        data

      any ->
        raise "#{inspect(any)}"
    end
  end

  def write!({port, _}, data) do
    true = Port.command(port, data)
  end

  def handle({port, _} = pts, {port, {:data, data}}), do: {pts, true, data}
  def handle(pts, _), do: {pts, false}

  def close({port, reset}) do
    # exception if port native process has died
    # ** (ArgumentError) argument error :erlang.port_close(#Port<0.6>)
    try do
      Port.close(port)
    after
      if reset, do: Nif.ttyreset()
    end
  end
end
