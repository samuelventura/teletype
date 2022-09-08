defmodule TeletypeTest do
  use ExUnit.Case
  doctest Teletype
  alias Teletype.Slave

  test "slave basic check" do
    {:ok, _} = :exec.start()
    exec = :code.priv_dir(:teletype) ++ '/master'
    opts = [:stdin, :stdout, {:stderr, :stdout}, :pty]
    {:ok, _, stdin} = :exec.run(exec, opts)
    # crash open -1 not such file or directory
    :timer.sleep(100)
    port = Slave.open("/tmp/slave.pts")
    Slave.write!(port, "ping")

    receive do
      {:stdout, _, "ping"} -> :ok
    end

    :ok = :exec.send(stdin, "pong")
    "pong" = Slave.read!(port)
  end
end
