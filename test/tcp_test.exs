defmodule TcpTest do
  use ExUnit.Case
  alias Teletype.Tcp

  @port 9980

  test "tcp basic check" do
    {:ok, pid} = Tcp.start_link(port: @port)
    {:ok, socket} = :gen_tcp.connect('127.0.0.1', @port, [:binary, packet: :raw, active: false])
    :ok = :gen_tcp.send(socket, "\e[s\e[999;999H\e[6n\e[u\e[H")
    {:ok, res} = :gen_tcp.recv(socket, 0)
    assert Regex.match?(~r/^\e\[(\d+);(\d+)R/, res)
    :ok = Tcp.stop(pid)
  end
end
