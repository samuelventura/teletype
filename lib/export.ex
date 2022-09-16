defmodule Teletype.Export do
  alias Teletype.Pts

  def start_link(tty, port) do
    Task.start_link(fn -> run(tty, port) end)
  end

  def run(tty, port) do
    opts = [
      :binary,
      ip: {0, 0, 0, 0},
      packet: :raw,
      active: true,
      reuseaddr: true
    ]

    {:ok, listener} = :gen_tcp.listen(port, opts)
    {:ok, socket} = :gen_tcp.accept(listener)
    port = Pts.open(tty)
    loop(listener, port, socket)
  end

  defp loop(listener, port, socket) do
    receive do
      {:tcp, _, data} ->
        Pts.write!(port, data)
        loop(listener, port, socket)

      {^port, {:data, data}} ->
        :gen_tcp.send(socket, data)
        loop(listener, port, socket)

      {:tcp_closed, _} ->
        {:ok, socket} = :gen_tcp.accept(listener)
        loop(listener, port, socket)

      any ->
        raise "#{inspect(any)}"
    end
  end
end
