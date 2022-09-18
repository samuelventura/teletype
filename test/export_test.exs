defmodule ExportTest do
  use ExUnit.Case
  doctest Teletype
  alias Teletype.Export

  test "export basic check" do
    {:ok, pid, port} = Export.start_link()
    {:ok, socket} = :gen_tcp.connect('127.0.0.1', port, [:binary, packet: :raw, active: false])
    :ok = :gen_tcp.send(socket, "\e[s\e[999;999H\e[6n\e[u\e[H")
    {:ok, res} = :gen_tcp.recv(socket, 0)
    assert Regex.match?(~r/^\e\[(\d+);(\d+)R/, res)
    :stop = Export.stop(pid)
  end
end
