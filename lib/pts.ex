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

  # {#Port<0.10>, {:exit_status, 143}}
  # {#Port<0.10>, {:data, <<>>}}
  def handle({port, _} = pts, {port, {:exit_status, _}}), do: {pts, :exit}
  def handle({port, _} = pts, {port, {:data, data}}), do: {pts, :data, data}
  def handle(pts, _), do: {pts, false}

  def close({port, reset}) do
    # exception if port native process has died
    # ** (ArgumentError) argument error :erlang.port_close(#Port<0.6>)
    # let the user choose to assert :ok = to except on close error
    try do
      true = Port.close(port)
      :ok
    rescue
      e -> {:error, e}
    after
      if reset, do: Nif.ttyreset()
    end
  end
end
