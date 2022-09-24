defmodule Teletype.Tcp do
  alias Teletype.Pts

  @toms 2_000

  def start_link(opts \\ []) do
    Task.start_link(fn -> start(opts) end)
  end

  def start(opts) do
    {port, opts} = Keyword.pop!(opts, :port)

    tcp_opts = [
      :binary,
      ip: {0, 0, 0, 0},
      packet: :raw,
      active: true,
      reuseaddr: true
    ]

    {:ok, listener} = :gen_tcp.listen(port, tcp_opts)
    {:ok, socket} = :gen_tcp.accept(listener)
    pts = Pts.open(opts)
    loop(listener, pts, opts, socket, listener, port)
  end

  def stop(pid, toms \\ @toms) do
    send(pid, {:stop, self()})

    receive do
      :stop -> :ok
    after
      toms ->
        Process.unlink(pid)
        Process.exit(pid, :kill)
        {:error, :timeout}
    end
  end

  # wont process messages during accept waits
  defp loop(listener, pts, opts, socket, listener, port) do
    receive do
      :SIGWINCH ->
        loop(listener, pts, opts, socket, listener, port)

      {:stop, pid} ->
        :gen_tcp.close(socket)
        :gen_tcp.close(listener)
        Pts.close(pts)
        send(pid, :stop)

      {:tcp, _, data} ->
        Pts.write!(pts, data)
        loop(listener, pts, opts, socket, listener, port)

      {:tcp_closed, _} ->
        Pts.close(pts)
        {:ok, socket} = :gen_tcp.accept(listener)
        pts = Pts.open(opts)
        loop(listener, pts, opts, socket, listener, port)

      msg ->
        case Pts.handle(pts, msg) do
          {pts, true, data} ->
            :gen_tcp.send(socket, data)
            loop(listener, pts, opts, socket, listener, port)

          _ ->
            raise "#{inspect(msg)}"
        end
    end
  end
end
