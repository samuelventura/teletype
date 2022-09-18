defmodule Teletype.Export do
  alias Teletype.Pts

  def start_link(opts \\ []) do
    pid = self()
    {:ok, pid} = Task.start_link(fn -> run(pid, opts) end)

    receive do
      {^pid, :port, port} -> {:ok, pid, port}
    end
  end

  def stop(pid, toms \\ 1000) do
    send(pid, {:stop, self()})

    receive do
      :stop -> :stop
    after
      toms ->
        Process.unlink(pid)
        Process.exit(pid, :kill)
        :kill
    end
  end

  defp run(pid, opts) do
    {port, opts} = Keyword.pop(opts, :pts, 0)

    tcp_opts = [
      :binary,
      ip: {0, 0, 0, 0},
      packet: :raw,
      active: true,
      reuseaddr: true
    ]

    {:ok, listener} = :gen_tcp.listen(port, tcp_opts)
    {:ok, {_ip, port}} = :inet.sockname(listener)
    send(pid, {self(), :port, port})
    {:ok, socket} = :gen_tcp.accept(listener)
    pts = Pts.open(opts)
    loop(listener, pts, socket, listener, port)
  end

  defp loop(listener, pts, socket, listener, port) do
    receive do
      {:stop, pid} ->
        :gen_tcp.close(socket)
        :gen_tcp.close(listener)
        Pts.close(pts)
        send(pid, :stop)

      {:tcp, _, data} ->
        Pts.write!(pts, data)
        loop(listener, pts, socket, listener, port)

      {:tcp_closed, _} ->
        {:ok, socket} = :gen_tcp.accept(listener)
        loop(listener, pts, socket, listener, port)

      msg ->
        case Pts.handle(pts, msg) do
          {pts, true, data} ->
            :gen_tcp.send(socket, data)
            loop(listener, pts, socket, listener, port)

          _ ->
            raise "#{inspect(msg)}"
        end
    end
  end
end
