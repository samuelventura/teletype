defmodule TeletypeTest do
  use ExUnit.Case
  doctest Teletype
  alias Teletype.Pts

  test "pts basic check" do
    {:ok, _} = :exec.start()
    exec = :code.priv_dir(:teletype) ++ '/ptm'
    opts = [:stdin, :stdout, {:stderr, :stdout}, :pty]
    {:ok, _, stdin} = :exec.run(exec, opts)
    # crash open -1 not such file or directory
    :timer.sleep(100)
    port = Pts.open(tty: "/tmp/teletype.pts")
    Pts.write!(port, "ping")

    receive do
      {:stdout, _, "ping"} -> :ok
    end

    :ok = :exec.send(stdin, "pong")
    "pong" = Pts.read!(port)
  end
end
